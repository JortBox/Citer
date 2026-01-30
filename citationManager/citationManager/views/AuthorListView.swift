//
//  AuthorListView.swift
//  Citer
//
//  Created by Jort Boxelaar on 17/02/2024.
//

import SwiftUI
import SwiftData

struct AuthorListView: View {
    @EnvironmentObject var navigationManager: NavigationStateManager
    
    let authors: [Author]
    @Binding var searchTerm: String
    
    
    var body: some View {
        if searchTerm.isEmpty {
            AuthorPerLetterView(authors: authors.unique(by: {$0.name}))
                .listStyle(.inset(alternatesRowBackgrounds: true))
                .navigationTitle(navigationManager.selectedCategory?.title() ?? "")
                .navigationSubtitle(navigationManager.selectedAuthor?.name ?? "")
        } else {
            let filteredAuthors = authors.filter({$0.name.localizedCaseInsensitiveContains(searchTerm)})
            List(filteredAuthors.unique(by: {$0.name}), selection: $navigationManager.selectedAuthor) { author in
                Label(author.name, systemImage: "person")
                    .tag(author)
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))
            .navigationTitle(navigationManager.selectedCategory?.title() ?? "")
            .navigationSubtitle(navigationManager.selectedAuthor?.name ?? "")
        }
    }
}

struct AuthorPerLetterView: View {
    @EnvironmentObject var navigationManager: NavigationStateManager
    @Query var papers: [Paper]
    
    let authors: [Author]
    var alphabet: [String] = "abcdefghijklmnopqrstuvwxyz".map({String($0)})
    
    var body: some View {
        List(alphabet, id: \.self, selection: $navigationManager.selectedAuthor) { char in
            Section(char.uppercased()) {
                ForEach(authors.filter({$0.name.lowercased().starts(with: char)})) { author in
                    Label(author.name, systemImage: "person")
                        //.badge(papers.filter({$0.authors.map({$0.name}).contains(author.name)}).count)
                        .tag(author)
                }
            }.listSectionSeparator(.hidden)
        }
    }
}


    
extension Array {
    func unique<T:Hashable>(by: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>()
        var arrayOrdered = [Element]()
        
        for value in self {
            if !set.contains(by(value)) {
                set.insert(by(value))
                arrayOrdered.append(value)
            }
        }
        return arrayOrdered
    }
}
