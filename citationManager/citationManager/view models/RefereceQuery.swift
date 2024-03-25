//
//  arxivQueryManual.swift
//  citationManager
//
//  Created by Jort Boxelaar on 21/01/2024.
//

import Foundation
import SwiftData
import SwiftUI

func ReferenceQuery(arXivID: String, completion: @escaping ([Reference]) -> Void) {
    //let path: String = "https://api.semanticscholar.org/graph/v1/paper/"
    //let fields: String = "title,year,authors,publicationDate,externalIds"
    //let url = URL(string: path + "ARXIV:" + arXivID + "/references?fields=" + fields)
    let path: String = "https://prophy.science/api/arxiv/"
    let url = URL(string: path + arXivID)

    let session = URLSession.shared
    
    session.dataTask(with: url!) { data, response, error in
        if let data = data {
            print(String(data: data, encoding: .utf8)!)
            let references = DecodeProphy(jsonData: data)
            
            completion(references)
            return
        }
        completion([])
    }.resume()
}

func ReferenceQuery(arXivId: String) async -> [Reference] {
    await withCheckedContinuation { continuation in
        ReferenceQuery(arXivID: arXivId) { messages in
            continuation.resume(returning: messages)
        }
    }
}

func DecodeProphy(jsonData: Data) -> [Reference]{
    let series = try? JSONSerialization.jsonObject(with: jsonData, options: [])
    var references: [Reference] = []
    
    if let dictionary = series as? [String: Any] {
        if let array = dictionary["references"] as? [Any] {
            for case let citation as [String: Any] in array {
                
                var authorsTemp: [String] = []
                var titleTemp: String = "Not Availible"
                var yearTemp: String = ""
                var arXivIdTemp: String = ""
                var doiTemp: String = ""
                
                //print("")
                //print("CITATION", citation)
                
                if let year = citation["year"] as? Int {
                    yearTemp = String("\(year)")
                    //print("YEAR", yearTemp)
                } else { print("year failed") }
                
                if let title = citation["title"] as? String {
                    titleTemp = title
                    //print("TITLE", titleTemp)
                } else { print("title failed") }
                
                if let arXivId = citation["arxivId"] as? String {
                    arXivIdTemp = arXivId
                    //print("ARXIV", arXivIdTemp)
                } else { print("arXiv Id Failed") }
                
                if let doi = citation["doi"] as? String {
                    doiTemp = doi
                    //print("DOI", doiTemp)
                } else { print("doi failed") }
                
                if let authorsArray = citation["authors"] as? [Any] {
                    for case let author as [String: Any] in authorsArray {
                        if let name = author["name"] as? String {
                            authorsTemp.append(name)
                        }
                    }
                }
                    
                let reference = Reference(bibcode: arXivIdTemp, title: titleTemp, year: yearTemp, arXivId: arXivIdTemp, doi: doiTemp, authors: authorsTemp)
                references.append(reference)
                authorsTemp.removeAll()
            }
        }
    } else { print("Unpacking Json Failed") }
    return references
}


func DecodeSchematic(jsonData: Data) -> [Reference] {
    let series = try? JSONSerialization.jsonObject(with: jsonData, options: [])
    var references: [Reference] = []
    
    if let dictionary = series as? [String: Any] {
        if let array = dictionary["data"] as? [Any] {
            for case let papers as [String: Any] in array {
                //let reference = ReferenceData(title: "Not Availible", publicationDate: Date(), arXivId: "Not Availible")
                var authorsTemp: [String] = []
                var titleTemp: String = "Not Availible"
                //var publicationDateTemp: Date = Date()
                var arXivIdTemp: String = ""
                var doiTemp: String = ""
                
                if let citation = papers["citedPaper"] as? [String: Any] {
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    /*
                    if let publicationDate = citation["publicationDate"] as? String {
                        publicationDateTemp = dateFormatter.date(from: publicationDate)!
                        //print(reference.publicationDate)
                    }
                    else if let publicationDate = citation["year"] as? String {
                        publicationDateTemp = dateFormatter.date(from: "\(publicationDate)-01-01")!
                        //print(reference.publicationDate)
                    } else {
                        publicationDateTemp = dateFormatter.date(from: "1000-01-01")!
                        //print(reference.publicationDate)
                    }
                     */
                    
                    if let title = citation["title"] as? String {
                        titleTemp = title
                        //print(reference.title)
                    }
                    
                    if let externalIds = citation["externalIds"] as? [String: Any] {
                        if let arXivId = externalIds["ArXiv"] as? String {
                            arXivIdTemp = arXivId
                        }
                        if let doi = externalIds["DOI"] as? String {
                            doiTemp = doi
                        }
                    }
                    
                    if let authorsArray = citation["authors"] as? [Any] {
                        for case let author as [String: Any] in authorsArray {
                            if let name = author["name"] as? String {
                                authorsTemp.append(name)
                                //reference.authors.append(AuthorData(name: name))
                            }
                        }
                    }
                }
                let reference = Reference(bibcode: arXivIdTemp, title: titleTemp, year: "YEAR", arXivId: arXivIdTemp, doi: doiTemp, authors: authorsTemp)
                print(reference.title, "YEAR", reference.arXivId)
                print(authorsTemp.description)
                //reference.authors.append(contentsOf: authorsTemp)
                references.append(reference)

                authorsTemp.removeAll()
            }
        }
    } else {
    }
    return references
}

