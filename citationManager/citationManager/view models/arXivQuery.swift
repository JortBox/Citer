//
//  arXivQuery.swift
//  citationManager
//
//  Created by Jort Boxelaar on 21/01/2024.
//

/*

import Foundation
import ArxivKit

func arXivQuery(arXivID: String) async -> Paper {
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    let paper: Paper
    var newAuthors: [Author] = []
    
    do {
        let response = try await ArxivIdList(arXivID).fetch(using: session)
        let article = response.entries[0]
        
        for author in article.authors {
            newAuthors.append(Author(name: author.name))
        }
        
        
        paper = Paper(bibcode: arXivID,
                      title: article.title,
                      publicationDate: article.submissionDate,
                      abstract: article.summary,
                      pdfLink: article.pdfURL.absoluteString,
                      webLink: article.abstractURL.absoluteString,
                      docLink: "\(documentsPath)/arXiv_" + article.id+".pdf",
                      authors: newAuthors,
                      arXivId: arXivID,
                      doi: article.doi,
                      year: Date().formatted(date: .numeric, time: .omitted)
        )
        Task {
            download(url: article.pdfURL, toFile: URL(filePath: "\(documentsPath)/arXiv_" + article.id+".pdf")) { (error) in
                if (error != nil) {
                    print(error!.localizedDescription)
                }
            }
        }
        return paper

    } catch {
        print("Could not fetch articles: \(error.localizedDescription)")
        paper = Paper(bibcode: arXivID, title: "", publicationDate: Date(), abstract: "", arXivId: arXivID, doi: "", year: Date().formatted(date: .numeric, time: .omitted))
        return paper
    }
   //return PaperData(title: "", publicationDate: Date(), abstract: "", arXivId: "")
}

*/
