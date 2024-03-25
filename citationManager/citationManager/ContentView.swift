//
//  ContentView.swift
//  citationManager
//
//  Created by Jort Boxelaar on 16/01/2024.
//

import SwiftUI
import SwiftData
import PDFKit


struct ContentView: View {
    @Query(sort: \Paper.title, animation: .default) var papers: [Paper]
    @Query(sort: \Author.name, animation: .default) var authors: [Author]
    @Query(sort: \Keyword.full, animation: .default) var keywords: [Keyword]
    
    @StateObject var navigationManager = NavigationStateManager()

    @State private var inspectorIsShown: Bool = false
    @State private var searchTerm: String = ""
    
    var uniqueAuthors: [String] {
         return Array(Set(authors.map({$0.name})))
            .filter({$0.localizedCaseInsensitiveContains(searchTerm)})
            .sorted { $0 < $1 }
    }
    
    var uniqueKeywords: [String] {
        return Array(Set(keywords.map({$0.full})))
            .filter({$0.localizedCaseInsensitiveContains(searchTerm)})
            .sorted { $0 < $1 }
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $navigationManager.columnVisibility, 
        sidebar: {
            
            SidebarView()
            
        }, content: {
            
            MiddleView(searchTerm: $searchTerm)
            
        }, detail: {
            
            DetailView(inspectorIsShown: $inspectorIsShown)
            
        })
        .environmentObject(navigationManager)
        .searchable(text: $searchTerm, placement: .toolbar,  prompt: "Search by Title or Author")
        .searchSuggestions {
            if !searchTerm.isEmpty {
                let filteredTitles = papers.filter({$0.title.localizedCaseInsensitiveContains(searchTerm)})
                let filteredAuthors = authors.unique(by: {$0.name}).filter({$0.name.localizedCaseInsensitiveContains(searchTerm)})
                let filteredKeywords = keywords.unique(by: {$0.full}).filter({$0.full.localizedCaseInsensitiveContains(searchTerm)})
                
                if !filteredTitles.isEmpty {
                    Section("Titles") {
                        ForEach(filteredTitles) { suggestion in
                            Label(suggestion.title, systemImage: "doc.text").lineLimit(1)
                                .searchCompletion(suggestion.title)
                        }
                    }
                }
                
                if !filteredAuthors.isEmpty {
                    Section("Authors") {
                        ForEach(filteredAuthors) { suggestion in
                            Label(suggestion.name, systemImage: "person").lineLimit(1)
                                .searchCompletion(suggestion.name)
                        }
                    }
                }
                
                if !filteredKeywords.isEmpty {
                    Section("Keywords") {
                        ForEach(filteredKeywords) { suggestion in
                            Label(suggestion.full, systemImage: "tag").lineLimit(1)
                                .searchCompletion(suggestion.full)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                ToolbarView(inspectorIsShown: $inspectorIsShown)
                    .environmentObject(navigationManager)
            }
        }
    }
}



struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
