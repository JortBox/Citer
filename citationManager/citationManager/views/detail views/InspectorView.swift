//
//  InspectorView.swift
//  Citer
//
//  Created by Jort Boxelaar on 06/02/2024.
//

import SwiftUI
import SwiftData

struct InspectorView: View {
    
    @State private var searchField: String = ""
    @Query var allPapers: [Paper]
    
    let paper: Paper
    
    var body: some View {
        TabView {
            VStack{
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
                
                List {
                    ForEach(bibliography) { bibitem in
                        var asociatedPaper: Paper? {
                            let paper = allPapers.filter({$0.bibcode == bibitem.bibcode})
                            if paper.count == 0 {
                                return nil
                            } else {
                                return paper.first
                            }
                        }
                        
                        if let asociatedPaper {
                            ReferenceView(reference: bibitem)
                                .contextMenu {
                                    PaperContextMenu(paper: asociatedPaper)
                                }
                        } else {
                            ReferenceView(reference: bibitem)
                            
                        }
                    }
                }
                .safeAreaInset(edge: .top) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search Bibliography By Author", text: $searchField)
                            .textFieldStyle(.plain)
                        if !searchField.isEmpty {
                            Button(action: {searchField = ""}, label: {Image(systemName: "multiply.circle.fill")})
                                .buttonStyle(.borderless)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                }
            }
            .scrollContentBackground(.hidden)
            .tabItem { Text("Bibliography") }

            InfoView(paperId: paper.id)
                .scrollContentBackground(.hidden)
                .frame(alignment: .topLeading)
                .tabItem { Text("Paper Info") }
        }
        .inspectorColumnWidth(min: 300, ideal: 400, max: 1000)
    }
}

