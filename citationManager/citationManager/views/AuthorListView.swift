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
    
    var body: some View {
        AuthorPerLetterView(authors: authors.unique(by: {$0.name}))
            .listStyle(.inset(alternatesRowBackgrounds: true))
            .navigationTitle(navigationManager.selectedCategory?.title() ?? "")
            .navigationSubtitle(navigationManager.selectedAuthor?.name ?? "")
    }
}

struct AuthorPerLetterView: View {
    @EnvironmentObject var navigationManager: NavigationStateManager
    @Query var papers: [Paper]
    
    let authors: [Author]
    var alphabet: [String] = "abcdefghijklmnopqrstuvwxyz".map({String($0)})
    
    var body: some View {
        List(selection: $navigationManager.selectedAuthor) {
            ForEach(alphabet, id: \.self) {char in
                Section(char.uppercased()) {
                    ForEach(authors.filter({$0.name.lowercased().starts(with: char)})) { author in
                        //Group{
                            Label(author.name, systemImage: "person")
                                .badge(papers.filter({$0.authors.map({$0.name}).contains(author.name)}).count)
                        //}
                        .tag(author)
                    }
                }
            }
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
