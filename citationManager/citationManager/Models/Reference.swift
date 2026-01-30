//
//  Reference.swift
//  citationManager
//
//  Created by Jort Boxelaar on 29/01/2024.
//

import Foundation
import SwiftData

@Model
final class Reference {
    var id = UUID()
    var bibcode: String
    var title: String
    var year: String
    var arXivId: String
    var doi: String
    var authors: [String]
    var authorList: String
    var citation: String = ""
    var citationWarning: Bool = true
    //@Relationship(inverse: \Paper.bibliography)
    
    init(bibcode: String, title: String, year: String = "", arXivId: String = "", doi: String = "", authors: [String] = []) {
        self.bibcode = bibcode
        self.title = title
        self.year = year
        self.arXivId = arXivId
        self.doi = doi
        self.authors = authors
        
        var surnames: [String] = []
        for name in authors {
            surnames.append(name.split(separator: ", ").first?.capitalized ?? name)
        }
        self.authorList = surnames.joined(separator: ", ")
    }
}
