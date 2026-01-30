//
//  MiddleView.swift
//  citationManager
//
//  Created by Jort Boxelaar on 02/02/2024.
//

import SwiftUI
import SwiftData

struct MiddleView: View {
    @EnvironmentObject var navigationManager: NavigationStateManager
    
    @Query(sort: \Paper.title, animation: .default) var papers: [Paper]
    @Query(sort: \Author.name, animation: .default) var authors: [Author]
    @Query(sort: \Keyword.full, animation: .default) var keywords: [Keyword]
    @Query(sort: \Object.name, animation: .default) var objects: [Object]
    
    @Binding var searchTerm: String
    @Binding var tokens: [FruitToken]
    @State private var sortOption: SortOption = .dateAdded
    @State private var invertSort: Bool = false
    
    
    var body: some View {
        if let category = navigationManager.selectedCategory {
            let filteredPapers: [Paper] = {
                switch category {
                case .all, .authors, .keywords, .objects: return papers
                case .unread: return papers.filter({!$0.read})
                case .read: return papers.filter({$0.read})
                case .favourites: return papers.filter({$0.favourite})
                case .readingList: return papers.filter({$0.inReadingList})
                case .list(let PaperGroup): return PaperGroup.papers
                case .tags(let PaperGroup): return papers.filter({PaperGroup.paperId.contains($0.bibcode)})
               }
            }()
            
            if searchTerm.isEmpty {
                switch category {
                case .all, .unread, .read, .favourites, .readingList, .list, .tags:
                    PaperListView(papers: filteredPapers,
                                  category: category,
                                  sortOption: $sortOption,
                                  inverseSort: $invertSort,
                                  paperViewMode: .small)
                case .authors:
                    AuthorListView(authors: authors, searchTerm: $searchTerm)
                case .keywords:
                    KeywordListView(keywords: keywords)
                case .objects:
                    ObjectListView(objects: objects, searchTerm: $searchTerm)
                }
            } else {
                switch category {
                case .all, .unread, .read, .favourites, .readingList, .list, .tags, .keywords:
                    let filteredAndSearchedPapers: [Paper] = {
                        if !tokens.isEmpty {
                            switch tokens.first! {
                            case .title:
                                return filteredPapers.filter({$0.title.localizedCaseInsensitiveContains(searchTerm)})
                            case .author:
                                return filteredPapers
                                    .filter({$0.authors.map({$0.name}).joined(separator: ", ").localizedCaseInsensitiveContains(searchTerm)})
                            case .tag:
                                return filteredPapers
                                    .filter({$0.objects.map({$0.name}).joined(separator: ", ").localizedCaseInsensitiveContains(searchTerm)})
                            }
                        } else {
                            return filteredPapers.filter({$0.title.localizedCaseInsensitiveContains(searchTerm)})
                        }
                        
                    }()
                    
                    PaperListView(papers: filteredAndSearchedPapers,
                                  category: category,
                                  sortOption: $sortOption,
                                  inverseSort: $invertSort,
                                  paperViewMode: .small)
                case .authors:
                    AuthorListView(authors: authors, searchTerm: $searchTerm)
                case .objects:
                    ObjectListView(objects: objects, searchTerm: $searchTerm)
                }
            }
        } else {
            EmptyView()
                //.background(.ultraThinMaterial)
        }
    }
}

enum SortOption {
    case title, dateAdded, year, author
}

enum PaperViewMode {
    case small, large
}
