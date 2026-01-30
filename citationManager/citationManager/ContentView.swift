//
//  ContentView.swift
//  citationManager
//
//  Created by Jort Boxelaar on 16/01/2024.
//

import SwiftUI
import SwiftData
import PDFKit

enum FruitToken: String, Identifiable, Hashable, CaseIterable {
    case title
    case author
    case tag
    var id: Self { self }
}

struct ContentView: View {
    //@EnvironmentObject private var model: SearchModel
    @Query(sort: \Paper.title, animation: .default) var papers: [Paper]
    @Query(sort: \Author.name, animation: .default) var authors: [Author]
    @Query(sort: \Object.name, animation: .default) var objects: [Object]
    
    @StateObject var navigationManager = NavigationStateManager()
    @State private var preferredColumn: NavigationSplitViewColumn = .detail

    @State private var inspectorTab: tabSelection = .bibliography
    
    @State private var inspectorIsShown: Bool = false
    @State private var searchTerm: String = ""
    @State private var tokens: [FruitToken] = []
    @State private var text: String = ""
    
    var uniqueAuthors: [String] {
         return Array(Set(authors.map({$0.name})))
            .filter({$0.localizedCaseInsensitiveContains(searchTerm)})
            .sorted { $0 < $1 }
    }
    
    var uniqueObjects: [String] {
        return Array(Set(objects.map({$0.name})))
            .filter({$0.localizedCaseInsensitiveContains(searchTerm)})
            .sorted { $0 < $1 }
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $navigationManager.columnVisibility, 
        sidebar: {
            SidebarView()
        }, content: {
            MiddleView(searchTerm: $searchTerm, tokens: $tokens)
        }, detail: {
            DetailView(inspectorIsShown: $inspectorIsShown)
        })
        .environmentObject(navigationManager)
        .searchable(text: $searchTerm, tokens: $tokens) { token in
            switch token {
            case .title: Text("Title")
            case .author: Text("Author")
            case .tag: Text("Object")
            }
        }
        .searchSuggestions {
            if tokens.isEmpty {
                ForEach(FruitToken.allCases, id: \.self) { token in
                    switch token {
                    case .title: Label("Title", systemImage: "character").searchCompletion(token)
                    case .author: Label("Author", systemImage: "person.fill").searchCompletion(token)
                    case .tag: Label("Object", systemImage: "hurricane").searchCompletion(token)
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
