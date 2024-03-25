//
//  KeywordSidebarGroup.swift
//  Citer
//
//  Created by Jort Boxelaar on 17/02/2024.
//

import SwiftUI
import SwiftData


struct KeywordListView: View {
    @EnvironmentObject var navigationManager: NavigationStateManager
    
    let keywords: [Keyword]
    
    var body: some View {
        var noSubKey: [Keyword] = []
        var uniqueFirst: [SubKeyword] {
            var finalList: [SubKeyword] = []
            for keyword in keywords {
                let sorted = keyword.subKeywords.sorted(by: {$0.timestamp < $1.timestamp})
                if keyword.subKeywords.count > 1 {
                    if !finalList.map({$0.value}).contains(sorted[0].value) {
                        finalList.append(sorted[0])
                    }
                } else {
                    if !noSubKey.map({$0.value}).contains(sorted[0].value) {
                        noSubKey.append(keyword)
                    }
                }
            }
            return finalList
        }
        List(selection: $navigationManager.selectedKeyword) {
            ForEach(uniqueFirst.sorted(by: {$0.value < $1.value})) { category in
                Section(category.value) {
                    var uniqueKeywords: [Keyword] {
                        var keywordList: [Keyword] = []
                        for keyword in keywords.filter({$0.subKeywords.sorted(by: {$0.timestamp < $1.timestamp})[0].value == category.value}) {
                            if !keywordList.map({$0.value}).contains(keyword.value) {
                                keywordList.append(keyword)
                            }
                        }
                        return keywordList
                    }
                    
                    ForEach(uniqueKeywords) { keyword in
                        let sortedKeywords = keyword.subKeywords.sorted(by: {$0.timestamp < $1.timestamp})
                        Label(sortedKeywords.map({$0.value}).dropFirst().joined(separator: ":"), systemImage: "tag" )
                            .tag(keyword)
                    }
                }
            }
            
            Section("Other") {
                ForEach(noSubKey) { keyword in
                    Label(keyword.full, systemImage: "tag")
                        .tag(keyword)
                }
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .navigationTitle(navigationManager.selectedCategory?.title() ?? "")
        .navigationSubtitle(navigationManager.selectedKeyword?.full ?? "")
    }
}


