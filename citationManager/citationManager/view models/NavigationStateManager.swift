//
//  ModelDataManager.swift
//  NavigationStackProject
//
//  Created by Karin Prater on 12.11.22.
//

import Foundation
import SwiftUI

class NavigationStateManager: ObservableObject {
    
    @Published var columnVisibility: NavigationSplitViewVisibility = .all
    @Published var selectedCategory: Category? = nil
    @Published var highlightMode: Bool = false
    
    @Published var selectedPaper: Paper? = nil {
        didSet {
            selectedID = selectedPaper?.bibcode
        }
    }
    @Published var selectedID: String? = nil
    
    @Published var selectedAuthor: Author? = nil {
        didSet {
            selectedAuthorID = selectedAuthor?.id.uuidString
        }
    }
    @Published var selectedAuthorID: String? = nil
    
    @Published var selectedKeyword: Keyword? = nil {
        didSet {
            selectedKeywordID = selectedKeyword?.id.uuidString
        }
    }
    @Published var selectedKeywordID: String? = nil
    
    
    func goToSettings() {
        //selectionState = .settings
    }
    
    func setSelectedPapers(to paper: Paper) {
        //selectionState = .book(book)
    }
    
}
