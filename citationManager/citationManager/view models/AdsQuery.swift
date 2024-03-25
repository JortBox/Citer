import Foundation

// https://api.adsabs.harvard.edu/v1/search/query?q=arXiv%3Aastro-ph%2F9808147&fl=title%2C+author%2C+doi%2C+identifier%2C+reference

private let token = "vEEfhBQylrWP6SvhgqOpwXYZboBmSB6lBcj6M0Rf"
private let scheme = "https"
private let host = "api.adsabs.harvard.edu"
private let path = "/v1/search/"

private let searchQueryKey = "q"
private let fieldsKey = "fl"
private let maxResultsKey = "rows"


func AdsQuery(paperId: String, completion: @escaping (Paper) -> Void) {
    let fieldsList = ["bibcode", "title", "author", "doi", "identifier", "reference", "year", "abstract","links_data", "keyword", "keyword_norm", "keyword_schema"]
    let session = URLSession.shared
    var url: URL {
        var components = URLComponents()
                
        components.scheme = scheme
        components.host = host
        components.path = path + "query"
        components.queryItems = []
        
        components.queryItems?.append(URLQueryItem(name: searchQueryKey, value: "bibcode:"+paperId))

        if !fieldsList.isEmpty {
            components.queryItems?.append(URLQueryItem(name: fieldsKey, value: fieldsList.joined(separator: ",")))
        }
        
        guard let finalURL = components.url else {
            fatalError("Unable to construct URL from ADS Request")
        }
        return finalURL
    }
    
    var request = URLRequest(url: url)
    
    request.setValue("Bearer:"+token, forHTTPHeaderField: "Authorization")
    session.dataTask(with: request) { data, response, error in
        //print("response ADS: ", response?.description as Any)
        if let data = data {
            print(String(data: data, encoding: .utf8)!)
            let paper = DecodeAdsPaper(jsonData: data,  paperId: paperId)
            
            completion(paper)
            return
        }
        completion(Paper(bibcode: paperId, title: "", abstract: "", arXivId: "", doi: "", year: ""))
    }.resume()
}

func AdsQuery(paperId: String) async -> Paper {
    await withCheckedContinuation { continuation in
        AdsQuery(paperId: paperId) { messages in
            continuation.resume(returning: messages)
        }
    }
}



func DecodeAdsPaper(jsonData: Data, paperId: String) -> Paper {
    let series = try? JSONSerialization.jsonObject(with: jsonData, options: [])
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let paper: Paper
    
    if let dictionary = series as? [String: Any] {
        if let response = dictionary["response"] as? [String: Any] {
            if let array = response["docs"] as? [Any] {
                if !array.isEmpty {
                    let article = array.first as! [String: Any]
                    var bibcodeTemp: String = ""
                    var titleTemp: String = "Not Availible"
                    var yearTemp: String = ""
                    var abstractTemp: String = "Not Availible"
                    var doiTemp: String = ""
                    var arXivIdTemp: String = ""
                    var authorsTemp: [Author] = []
                    var referencesTemp: [String] = []
                    var keywordsTemp: [Keyword] = []
                    var pdfURL: String = ""
                    
                    if let bibcode = article["bibcode"] as? String {
                        bibcodeTemp = bibcode
                    } else { print("bibcode failed") }
                    
                    if let title = article["title"] as? [String] {
                        titleTemp = title.first!
                    } else { print("title failed") }
                    
                    if let year = article["year"] as? String {
                        yearTemp = String("\(year)")
                    } else { print("year failed") }
                    
                    if let abstract = article["abstract"] as? String {
                        abstractTemp = abstract
                    } else { print("abstract failed") }
                    
                    if let doi = article["doi"] as? [String] {
                        if !doi.isEmpty {
                            doiTemp = doi.first!
                        }
                    } else { print("doi failed") }
                    
                    if let arXivId = article["identifier"] as? [String] {
                        if !arXivId.isEmpty {
                            for articleCode in arXivId {
                                if articleCode.contains("arXiv:") {
                                    arXivIdTemp = articleCode.split(separator: ":").last?.lowercased() ?? ""
                                }
                                else if articleCode.contains("arXiv."), !arXivIdTemp.isEmpty {
                                    arXivIdTemp = articleCode.split(separator: ".").suffix(2).joined(separator: ".")
                                }
                                //else if articleCode.contains("arXiv") {
                                //    arXivIdTemp = articleCode
                                //}
                            }
                        }
                    } else { print("arxivId failed") }
                    
                    if let keywords = article["keyword"] as? [String] {
                        for keyword in keywords {
                            keywordsTemp.append(Keyword(keyword))
                        }
                    } else { print("keyword failed") }
                    
                    if let authors = article["author"] as? [String] {
                        for author in authors {
                            authorsTemp.append(Author(name: author))
                        }
                    } else { print("author failed") }
                    
                    if let references = article["reference"] as? [String] {
                        if !references.isEmpty{
                            referencesTemp.append(contentsOf: references)
                        }
                    } else { print("reference failed") }
                    
                    if let linksData = article["links_data"] as? [Any] {
                        if !linksData.isEmpty {
                            for case let linkData as [String: Any] in linksData {
                                if linkData["type"] as! String == "pdf" {
                                    pdfURL = linkData["url"] as! String
                                }
                            }
                        }
                    }
                    
                    let abstractURL = "https://ui.adsabs.harvard.edu/abs/" + bibcodeTemp
                    if pdfURL.isEmpty, !arXivIdTemp.isEmpty {
                        pdfURL = "https://arxiv.org/pdf/" + arXivIdTemp + ".pdf"
                    }
                    
                    if pdfURL.isEmpty {
                        pdfURL = "https://articles.adsabs.harvard.edu/pdf/" + bibcodeTemp
                    }
                    
                    if bibcodeTemp != paperId {
                        print("ERROR: retreived bibcode does not match passed paperID!")
                    }
                    
                    paper = Paper(bibcode: paperId,
                                  title: titleTemp,
                                  abstract: abstractTemp,
                                  pdfLink: pdfURL,
                                  webLink: abstractURL,
                                  docLink: "\(documentsPath)/" + bibcodeTemp + ".pdf",
                                  authors: authorsTemp,
                                  arXivId: arXivIdTemp,
                                  doi: doiTemp,
                                  year: yearTemp,
                                  referenceIds: referencesTemp,
                                  keywords: keywordsTemp
                                  )
                    
                    download(url: paper.pdfLink!, toFile: paper.docLink!) { (error) in
                        if (error != nil) {
                            print(error!.localizedDescription)
                        }
                    }
                    return paper
                }
            }
        }
    }
    return Paper(bibcode: paperId, title: "", abstract: "", arXivId: "", doi: "", year: "")
}






func ReferencesQuery(paperIds: [String], completion: @escaping ([Reference]) -> Void) {
    let fieldsList = ["bibcode", "identifier", "doi", "title", "year", "author"]
    let session = URLSession.shared
    var bodyDataString: String = "bibcode"
    
    for id in paperIds {
        bodyDataString += "\n\(id)"
    }
    
    var url: URL {
        var components = URLComponents()
                
        components.scheme = scheme
        components.host = host
        components.path = path + "bigquery"
        components.queryItems = []
        
        components.queryItems?.append(URLQueryItem(name: searchQueryKey, value: "*:*"))
        if !fieldsList.isEmpty {
            components.queryItems?.append(URLQueryItem(name: fieldsKey, value: fieldsList.joined(separator: ",")))
        }
        components.queryItems?.append(contentsOf: [URLQueryItem(name: maxResultsKey, value: "500")])
        
        guard let finalURL = components.url else {
            fatalError("Unable to construct URL from ADS Request")
        }
        return finalURL
    }
    
    var request = URLRequest(url: url)
    
    request.setValue("Bearer:"+token, forHTTPHeaderField: "Authorization")
    request.setValue("big-query/csv", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = bodyDataString.data(using: .utf8)
    
    session.dataTask(with: request) { data, response, error in
        //print("response reference: ", response?.description as Any)
        if let data = data {
            //print(String(data: data, encoding: .utf8)!)
            let references = DecodeAdsReference(jsonData: data)
            
            completion(references)
            return
        }
        completion([])
    }.resume()
}

func ReferencesQuery(paperIds: [String]) async -> [Reference] {
    await withCheckedContinuation { continuation in
        ReferencesQuery(paperIds: paperIds) { messages in
            continuation.resume(returning: messages)
        }
    }
}


func DecodeAdsReference(jsonData: Data) -> [Reference] {
    let series = try? JSONSerialization.jsonObject(with: jsonData, options: [])
    var references: [Reference] = []
    
    if let dictionary = series as? [String: Any] {
        if let response = dictionary["response"] as? [String: Any] {
            if let array = response["docs"] as? [Any] {
                for case let article as [String: Any] in array {
                    
                    var bibcodeTemp: String = ""
                    var titleTemp: String = "Not Availible"
                    var yearTemp: String = ""
                    var doiTemp: String = ""
                    var arXivIdTemp: String = ""
                    var authorsTemp: [String] = []
                    
                    if let bibcode = article["bibcode"] as? String {
                        bibcodeTemp = bibcode
                    } else { print("bibcode failed") }
                    
                    if let title = article["title"] as? [String] {
                        titleTemp = title.first!
                    } else { print("title failed") }
                    
                    if let year = article["year"] as? String {
                        yearTemp = String("\(year)")
                    } else { print("year failed") }
                    
                    if let doi = article["doi"] as? [String] {
                        if !doi.isEmpty {
                            doiTemp = doi.first!
                        }
                    } else { print("doi failed") }
                    
                    if let arXivId = article["identifier"] as? [String] {
                        if !arXivId.isEmpty {
                            for articleCode in arXivId {
                                if articleCode.contains("arXiv:") {
                                    arXivIdTemp = articleCode.split(separator: ":").last?.lowercased() ?? ""
                                }
                                else if articleCode.contains("arXiv."), !arXivIdTemp.isEmpty {
                                    arXivIdTemp = articleCode.suffix(10).lowercased()
                                }
                                //else if articleCode.contains("arXiv") {
                                //    arXivIdTemp = articleCode
                                //}
                            }
                        }
                    } else { print("arxivId failed") }
                    
                    if let authors = article["author"] as? [String] {
                        for author in authors {
                            authorsTemp.append(author)
                        }
                    } else { print("author failed") }
                    
                    let reference = Reference(bibcode: bibcodeTemp,
                                              title: titleTemp,
                                              year: yearTemp,
                                              arXivId: arXivIdTemp,
                                              doi: doiTemp,
                                              authors: authorsTemp)
                    
                    references.append(reference)
                    authorsTemp.removeAll()
                }
            }
        }
    }
    return references
}


func download(url: URL, toFile file: URL, completion: @escaping (Error?) -> Void) {
    // Download the remote URL to a file
    let task = URLSession.shared.downloadTask(with: url) {
        (tempURL, response, error) in
        // Early exit on error
        print("response Download: ", response?.description as Any)
        
        guard let tempURL = tempURL else {
            completion(error)
            return
        }
        do {
            if FileManager.default.fileExists(atPath: file.path) {
                try FileManager.default.removeItem(at: file)
            }
            try FileManager.default.copyItem(
                at: tempURL,
                to: file
            )
            
            try FileManager.default.removeItem(at: tempURL)
            completion(nil)
        }
        catch {
            print("Download error: \(error)")
            completion(error)
        }
    }
    task.resume()
}
