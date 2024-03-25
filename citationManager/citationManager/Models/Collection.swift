//
//  CollectionData.swift
//  citationManager
//
//  Created by Jort Boxelaar on 24/01/2024.
//

import Foundation
import SwiftData

@Model
final class Collection {
    let id = UUID()
    var title: String
    var dateAdded: Date
    var papers = [Paper]()
    
    init(title: String) {
        self.title = title
        self.dateAdded = Date()
    }
}
