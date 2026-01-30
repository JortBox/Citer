//
//  ReferenceListView.swift
//  Citer
//
//  Created by Jort Boxelaar on 09/12/2024.
//

import SwiftUI
import SwiftData

struct ReferenceListView: View {
    @Query var allPapers: [Paper]
    
    let paper: Paper
    @Binding var searchField: String
    
    @State private var showDialog: Bool = false
    
    var body: some View {
        var bibliography: [Reference] {
            if searchField.isEmpty {
                return paper.bibliography
                    .filter({!$0.authors.isEmpty})
                    .sorted(by: {$0.authorList < $1.authorList})
            } else {
                return paper.bibliography
                    .filter({!$0.authors.isEmpty})
                    .filter({$0.authorList.localizedCaseInsensitiveContains(searchField)})
                    .sorted(by: {$0.authorList < $1.authorList})
            }
        }
        
        ForEach(bibliography) { bibitem in
            var asociatedPaper: Paper? {
                let paper = allPapers.filter({$0.bibcode == bibitem.bibcode})
                if paper.count == 0 {
                    return nil
                } else {
                    return paper.first
                }
            }
            ReferenceView(reference: bibitem, asociatedPaper: asociatedPaper)
                .contextMenu {
                    if let asociatedPaper {
                        PaperContextMenu(paper: asociatedPaper, showDialog: $showDialog)
                    }
                }
        }
    }
}

