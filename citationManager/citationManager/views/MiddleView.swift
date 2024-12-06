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
    @State private var sortOption: SortOption = .dateAdded
    
    var body: some View {
        if let category = navigationManager.selectedCategory {
            
            if searchTerm.isEmpty {
                switch category {
                case .all:
                    PaperListView(papers: papers, 
                                  category: category,
                                  sortOption: $sortOption,
                                  paperViewMode: .small)
                    
                case .unread:
                    PaperListView(papers: papers.filter({!$0.read}), 
                                  category: category,
                                  sortOption: $sortOption,
                                  paperViewMode: .small)
                    
                case .read:
                    PaperListView(papers: papers.filter({$0.read}), 
                                  category: category,
                                  sortOption: $sortOption,
                                  paperViewMode: .small)
                    
                case .favourites:
                    PaperListView(papers: papers.filter({$0.favourite}), 
                                  category: category,
                                  sortOption: $sortOption,
                                  paperViewMode: .small)
                    
                case .readingList:
                    PaperListView(papers: papers.filter({$0.inReadingList}), 
                                  category: category,
                                  sortOption: $sortOption,
                                  paperViewMode: .small)
                    
                case .list(let PaperGroup):
                    PaperListView(papers: PaperGroup.papers, 
                                  category: category,
                                  sortOption: $sortOption,
                                  paperViewMode: .small)
                    
                case .tags(let PaperGroup):
                    PaperListView(papers: papers.filter({PaperGroup.paperId.contains($0.bibcode)}),
                                  category: category,
                                  sortOption: $sortOption,
                                  paperViewMode: .small)
                    
                case .authors:
                    AuthorListView(authors: authors)
                    
                case .keywords:
                    KeywordListView(keywords: keywords)
                    
                case .objects:
                    ObjectListView(objects: objects)
                }
                
            
            } else {
                switch category {
                case .all, .read, .unread, .readingList, .favourites, .list(_), .tags(_):
                    PaperListView(papers: papers
                        .filter({$0.title.localizedCaseInsensitiveContains(searchTerm) || $0.authors.map({$0.name}).contains(searchTerm) || $0.keywords.map({$0.full}).contains(searchTerm)}),
                                  category: category,
                                  sortOption: $sortOption,
                                  paperViewMode: .small)
                case .authors:
                    AuthorListView(authors: authors.filter({$0.name.localizedCaseInsensitiveContains(searchTerm)}))
                case .keywords:
                    KeywordListView(keywords: keywords.filter({$0.full.localizedCaseInsensitiveContains(searchTerm)}))
                case .objects:
                    ObjectListView(objects: objects.filter({$0.name.localizedCaseInsensitiveContains(searchTerm)}))
                }
            }
            
        } else {
            EmptyView()
                .background(.ultraThinMaterial)
        }
    }
}

enum SortOption {
    case title, dateAdded, year
}

enum PaperViewMode {
    case small, large
}
