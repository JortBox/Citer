//
//  ReferenceContextMenu.swift
//  Citer
//
//  Created by Jort Boxelaar on 12/04/2024.
//

import SwiftUI

struct ReferenceContextMenu: View {
    let reference: Reference
    
    var body: some View {
        Button("Copy Bibcode") {
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
            pasteboard.setString(reference.bibcode, forType: NSPasteboard.PasteboardType.string)
        }
        
    }
}

