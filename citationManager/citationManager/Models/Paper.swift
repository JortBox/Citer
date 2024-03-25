//
//  PaperData.swift
//  citationManager
//
//  Created by Jort Boxelaar on 20/01/2024.
//

import Foundation
import SwiftData
//import ArxivKit


@Model
final class Paper {
    let id = UUID()
    var title: String
    var publicationDate: Date
    var dateAdded: Date
    var abstract: String
    var pdfLink: URL?
    var webLink: URL?
    var docLink: URL?
    var favourite: Bool = false
    var read: Bool = false
    var inReadingList: Bool = false
    var new: Bool = true
    var doi: String
    var arXivId: String
    var year: String
    var referenceIds: [String]
    
    @Attribute(.unique) var bibcode: String
    @Relationship(deleteRule: .cascade) var authors: [Author]
    @Relationship(deleteRule: .nullify) var bibliography: [Reference]
    @Relationship(deleteRule: .cascade) var keywords: [Keyword]
    
    init(bibcode: String,
         title: String,
         publicationDate: Date = Date(),
         abstract: String,
         pdfLink: String = "",
         webLink: String = "",
         docLink: String = "",
         authors: [Author] = [],
         bibliography: [Reference] = [],
         dateAdded: Date = Date(),
         arXivId: String,
         doi: String,
         year: String,
         referenceIds: [String] = [],
         keywords: [Keyword] = []
    ) {
        self.title = title
        self.publicationDate = publicationDate
        self.abstract = abstract
        self.pdfLink = URL(string: pdfLink)
        self.webLink = URL(string: webLink)
        self.docLink = URL(filePath: docLink)
        self.arXivId = arXivId
        self.doi = doi
        self.authors = authors
        self.bibliography = bibliography
        self.dateAdded = dateAdded
        self.bibcode = bibcode
        self.year = year
        self.referenceIds = referenceIds
        self.keywords = keywords
    }
}


@ModelActor
actor DataHandler {}

extension DataHandler {
    func updateItem(_ paper: Paper, bibliography: [Reference]) throws {
        print("updating item")
        paper.bibliography.append(contentsOf: bibliography)
        
        print("saving changes")
        print(paper.bibliography.count)
        do {
            try modelContext.save()
        } catch {
            print("send error: \(error)")
        }
        print("changes saved")
    }

    func newItem(paperId: String) async throws -> Paper {
        //let integers = ["0","1","2","3","4","5","6","7","8","9"]
        //if integers.contains(String(paperId.last!)) {
            //print("ARXIV")
            //let paper = await arXivQuery(arXivID: paperId)
            //modelContext.insert(paper)
            //try modelContext.save()
        //    return nil
        //} else {
            let paper = await AdsQuery(paperId: paperId)
            modelContext.insert(paper)
            try modelContext.save()
            return paper
        //}

    }
    
    func deleteItem(_ paper: Paper) throws {
        if let file = paper.pdfLink {
            try FileManager.default.removeItem(at: file)
        }
        modelContext.delete(paper)
        do {
            try modelContext.save()
        } catch {
            print("send error: \(error)")
        }
    }

}
