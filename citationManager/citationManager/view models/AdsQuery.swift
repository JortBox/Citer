import Foundation

private let token = UserDefaults.standard.string(forKey: "adsToken") ?? ""
private let scheme = "https"
private let host = "api.adsabs.harvard.edu"
private let path = "/v1/search/"

private let searchQueryKey = "q"
private let fieldsKey = "fl"
private let maxResultsKey = "rows"

func AdsQuery(paperId: String, completion: @escaping (Paper) -> Void) {
    let fieldsList = ["bibcode", "title", "author", "doi", "identifier", "reference", "year", "abstract","links_data", "keyword", "keyword_norm", "keyword_schema", "nedid", "date", "issue", "pub", "volume", "bibstem", "page_range", "page"]
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
    print("token",token)
    
    request.setValue("Bearer "+token, forHTTPHeaderField: "Authorization")
    session.dataTask(with: request) { data, response, error in
        print("response ADS: ", response?.description as Any)
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
    var paper: Paper
    
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
                    var nedIdTemp: [Object] = []
                    var authorsTemp: [Author] = []
                    var referencesTemp: [String] = []
                    var keywordsTemp: [Keyword] = []
                    var pdfURL: String = ""
                    var VizierCatalogTemp: [Catalog] = []
                    var dateTemp: String = ""
                    var issueTemp: String = ""
                    var volumeTemp: String = ""
                    //var pubTemp: String = ""
                    var pagesTemp: String = ""
                    var bibstemTemp: String = ""
                    
                    
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
                    
                    if let nedId = article["nedid"] as? [String] {
                        for nedIdCode in nedId {
                            nedIdTemp.append(Object(nedIdCode))
                        }
                    }
                    else { print("nedid failed") }
                    
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
                    
                    //"date", "issue", "pub", "volume", "bibstem", "page_range", "page"
                    if let date = article["date"] as? String {
                        dateTemp = date
                    } else { print("date failed") }
                    
                    if let issue = article["issue"] as? String {
                        issueTemp = issue
                    } else { print("issue failed") }
                    
                    if let volume = article["volume"] as? String {
                        volumeTemp = volume
                    } else { print("volume failed") }
                    
                    if let bibstem = article["bibstem"] as? [String] {
                        bibstemTemp = bibstem.first ?? ""
                    } else { print("bibstem failed") }
                    
                    if let page_range = article["page_range"] as? String {
                        pagesTemp = page_range
                    } else if let page = article["page"] as? [String] {
                        pagesTemp = page.first ?? ""
                    } else { print("page failed") }
                    
                    if let linksData = article["links_data"] as? [Any] {
                        if !linksData.isEmpty {
                            for linkData in linksData {
                                if let dict: [String: Any] = convertToDictionary(text: linkData as! String) {
                                    if dict["type"] as! String == "pdf" {
                                        pdfURL = dict["url"] as! String
                                    }
                                    else if dict["type"] as! String == "data" {
                                        VizierCatalogTemp.append(Catalog(dict["url"] as! String))
                                    }
                                } else { print("linkData failed") }
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
                                  keywords: keywordsTemp,
                                  objects: nedIdTemp,
                                  catalogs: VizierCatalogTemp
                                  )
                    
                    paper = ExportCitation(paper: paper, date: dateTemp, issue: issueTemp, volume: volumeTemp, bibstem: bibstemTemp, pages: pagesTemp)
                    print(paper.citation)
                    print(paper.citationWarning)
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
    let fieldsList = ["bibcode", "identifier", "doi", "title", "year", "author", "date", "issue", "pub", "volume", "bibstem", "page_range", "page"]
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
    
    request.setValue("Bearer "+token, forHTTPHeaderField: "Authorization")
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
                    var dateTemp: String = ""
                    var issueTemp: String = ""
                    var volumeTemp: String = ""
                    var pagesTemp: String = ""
                    var bibstemTemp: String = ""
                    
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
                    
                    //"date", "issue", "pub", "volume", "bibstem", "page_range", "page"
                    if let date = article["date"] as? String {
                        dateTemp = date
                    } else { print("date failed") }
                    
                    if let issue = article["issue"] as? String {
                        issueTemp = issue
                    } else { print("issue failed") }
                    
                    if let volume = article["volume"] as? String {
                        volumeTemp = volume
                    } else { print("volume failed") }
                    
                    if let bibstem = article["bibstem"] as? [String] {
                        bibstemTemp = bibstem.first ?? ""
                    } else { print("bibstem failed") }
                    
                    if let page_range = article["page_range"] as? String {
                        pagesTemp = page_range
                    } else if let page = article["page"] as? [String] {
                        pagesTemp = page.first ?? ""
                    } else { print("page failed") }
                    
                    var reference = Reference(bibcode: bibcodeTemp,
                                              title: titleTemp,
                                              year: yearTemp,
                                              arXivId: arXivIdTemp,
                                              doi: doiTemp,
                                              authors: authorsTemp)
                    
                    reference = ExportRefCitation(reference: reference, date:dateTemp, issue:issueTemp, volume: volumeTemp, bibstem: bibstemTemp, pages: pagesTemp)
                    
                    references.append(reference)
                    authorsTemp.removeAll()
                }
            }
        }
    }
    return references
}


func download(url: URL, toFile file: URL, completion: @escaping (Error?) -> Void) {
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


func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
// http://tapvizier.u-strasbg.fr/TAPVizieR/tap/tables/VIII/65



func ExportCitation(paper: Paper, date: String, issue: String, volume: String, bibstem: String, pages: String) -> Paper {
    var citationWarning: Bool = false
    var citation: String = "@article{\(paper.bibcode),\n"
    
    var monthString: String {
        let month: String = "\(date.split(separator: "-")[1])"
        if month == "01" { return "month = feb,\n"}
        else if month == "02" { return "month = feb,\n"}
        else if month == "03" { return "month = mar,\n"}
        else if month == "04" { return "month = apr,\n"}
        else if month == "05" { return "month = may,\n"}
        else if month == "06" { return "month = jun,\n"}
        else if month == "07" { return "month = jul,\n"}
        else if month == "08" { return "month = aug,\n"}
        else if month == "09" { return "month = sep,\n"}
        else if month == "10" { return "month = oct,\n"}
        else if month == "11" { return "month = nov,\n"}
        else if month == "12" { return "month = dec,\n"}
        else {
            citationWarning = true
            return ""
        }
    }
    
    var issueString: String {
        if !issue.isEmpty {
            return "number = {\(issue)},\n"
        } else {
            citationWarning = true
            return ""
        }
    }
    
    var keywordsString: String {
        let keywords = paper.keywords.map({$0.full}).joined(separator: ",")
        if !keywords.isEmpty {
            return "keywords = {\(keywords)},\n"
        } else {
            citationWarning = true
            return ""
        }
    }
    
    var eprintString: String {
        if !paper.arXivId.isEmpty {
            return "eprint = {\(paper.arXivId)},\n    archivePrefix {arXiv},\n"
        } else {
            citationWarning = true
            return ""
        }
    }
    
    var doiString: String {
        if !paper.doi.isEmpty {
            return "doi = {\(paper.doi)},\n"
        } else {
            citationWarning = true
            return ""
        }
    }
    
    let authorList = paper.authors
        .sorted(by: {$0.timestamp < $1.timestamp})
        .map({$0.name})
        .joined(separator: " and ")
    
    var citationSuffix: String = "    author = {\(authorList)},\n    title = \"{\(paper.title)}\",\n    year = \(paper.year),\n    \(monthString)    doi = {\(paper.doi)},\n    journal = {\(bibstem)},\n    volume = {\(volume)},\n    \(issueString)    pages = {\(pages)},\n    \(keywordsString)    \(eprintString)    adsurl = {https://ui.adsabs.harvard.edu/abs/\(paper.bibcode)}\n}"
    citationSuffix = citationSuffix.replacingOccurrences(of: "&", with: "\\&")
    citationSuffix = citationSuffix.replacingOccurrences(of: "ö", with: "\\\"o")
    
    citation.append(citationSuffix)
    paper.citation = citation
    paper.citationWarning = citationWarning
    return paper
}

func ExportRefCitation(reference: Reference, date: String, issue: String, volume: String, bibstem: String, pages: String) -> Reference {
    var citationWarning: Bool = false
    var citation: String = "@article{\(reference.bibcode),\n"
    
    var monthString: String {
        let month: String = "\(date.split(separator: "-")[1])"
        if month == "01" { return "month = feb,\n"}
        else if month == "02" { return "month = feb,\n"}
        else if month == "03" { return "month = mar,\n"}
        else if month == "04" { return "month = apr,\n"}
        else if month == "05" { return "month = may,\n"}
        else if month == "06" { return "month = jun,\n"}
        else if month == "07" { return "month = jul,\n"}
        else if month == "08" { return "month = aug,\n"}
        else if month == "09" { return "month = sep,\n"}
        else if month == "10" { return "month = oct,\n"}
        else if month == "11" { return "month = nov,\n"}
        else if month == "12" { return "month = dec,\n"}
        else {
            citationWarning = true
            return ""
        }
    }
    
    var issueString: String {
        if !issue.isEmpty {
            return "number = {\(issue)},\n"
        } else {
            citationWarning = true
            return ""
        }
    }
    /*
    var keywordsString: String {
        let keywords = paper.keywords.map({$0.full}).joined(separator: ",")
        if !keywords.isEmpty {
            return "keywords = {\(keywords)},\n"
        } else {
            citationWarning = true
            return ""
        }
    }*/
    
    var eprintString: String {
        if !reference.arXivId.isEmpty {
            return "eprint = {\(reference.arXivId)},\n    archivePrefix {arXiv},\n"
        } else {
            citationWarning = true
            return ""
        }
    }
    
    var doiString: String {
        if !reference.doi.isEmpty {
            return "doi = {\(reference.doi)},\n"
        } else {
            citationWarning = true
            return ""
        }
    }
    
    let authorList = reference.authors.joined(separator: " and ")
    
    var citationSuffix: String = "    author = {\(authorList)},\n    title = \"{\(reference.title)}\",\n    year = \(reference.year),\n    \(monthString)    \(doiString)    journal = {\(bibstem)},\n    volume = {\(volume)},\n    \(issueString)    pages = {\(pages)},\n    \(eprintString)    adsurl = {https://ui.adsabs.harvard.edu/abs/\(reference.bibcode)}\n}"
    citationSuffix = citationSuffix.replacingOccurrences(of: "&", with: "\\&")
    citationSuffix = citationSuffix.replacingOccurrences(of: "ö", with: "\\\"o")
    
    citation.append(citationSuffix)
    reference.citation = citation
    reference.citationWarning = citationWarning
    return reference
}
