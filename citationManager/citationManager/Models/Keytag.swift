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
    let id = UUID()
    var title: String
    var displayTitle: String
    var creationDate: Date
    var papers = [Paper]()
    
    init(title: String, papers: [Paper] = [Paper]()) {
        self.title = title
        self.papers = papers
        self.creationDate = Date()
        self.displayTitle = String("#\(title)")
        
    }
}
