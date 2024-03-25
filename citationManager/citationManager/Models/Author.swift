//
//  Author.swift
//  citationManager
//
//  Created by Jort Boxelaar on 29/01/2024.
//

import Foundation
import SwiftData

@Model
final class Author {
    let id = UUID()
    var name: String
    var surname: String
    let timestamp: Date
    
    init(name: String, timestamp: Date = Date()) {
        self.name = name
        self.surname = name.split(separator: ".").last?.capitalized ?? name
        self.timestamp = timestamp
    }
}
