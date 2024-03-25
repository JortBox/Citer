//
//  AuthorBibliography.swift
//  citationManager
//
//  Created by Jort Boxelaar on 03/02/2024.
//

import Foundation
import SwiftData

@Model
final class AuthorBibliography {
    @Attribute(.unique) var name: String
    var papers = [Paper]()
    var papercount: Int
    
    init(name: String, papers: [Paper] = [Paper]()) {
        self.name = name
        self.papers = papers
        self.papercount = papers.count
    }
}
