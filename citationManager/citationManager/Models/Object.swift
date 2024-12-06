//
//  Object.swift
//  Citer
//
//  Created by Jort Boxelaar on 06/12/2024.
//

import Foundation
import SwiftData

@Model
final class Object {
    var id = UUID()
    var name: String
    var display:String
    
    init(_ name: String) {
        self.name = name
        self.display = name.uppercased().split(separator: ":").first?.replacingOccurrences(of: "_", with: " ") ?? name.uppercased().replacingOccurrences(of: "_", with: " ")
    }
}
