//
//  Keytag.swift
//  Citer
//
//  Created by Jort Boxelaar on 19/02/2024.
//

import Foundation
import SwiftData

@Model
final class Tag {
    var id = UUID()
    var title: String
    var displayTitle: String
    var creationDate: Date
    var papers: [Paper]
    var paperId = [String]()
    
    init(title: String, papers: [Paper] = []) {
        self.title = title
        self.papers = papers
        self.creationDate = Date()
        self.displayTitle = String("#\(title)")
        self.paperId = paperId
        
    }
}
