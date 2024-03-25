//
//  Keyword.swift
//  Citer
//
//  Created by Jort Boxelaar on 17/02/2024.
//

import Foundation
import SwiftData

@Model
final class Keyword {
    let id = UUID()
    var full: String
    var subKeywords = [SubKeyword]()
    var value: String
    var isCustom: Bool = false
    
    init(_ fullKeyword: String, isCustom: Bool = false) {
        let splitKeywords = fullKeyword.split(separator: ":")
        var subKeywords: [SubKeyword] = []
        
        self.full = fullKeyword.lowercased()
        self.value = splitKeywords.last?.lowercased() ?? ""
        self.isCustom = isCustom
        
        for key in splitKeywords {
            subKeywords.append(SubKeyword(String(key.lowercased())))
        }
        
        self.subKeywords.append(contentsOf: subKeywords)
    }
}

@Model
final class SubKeyword {
    let id = UUID()
    var value: String
    let timestamp: Date
    
    init(_ value: String) {
        self.value = value
        self.timestamp = Date()
    }
}
