//
//  PaperListView.swift
//  Citer
//
//  Created by Jort Boxelaar on 06/02/2024.
//

import SwiftUI

struct PaperListView: View {
    @EnvironmentObject var navigationManager: NavigationStateManager
    
    let papers: [Paper]
    let category: Category
    
    @Binding var sortOption: SortOption
    @Binding var inverseSort: Bool
    var paperViewMode: PaperViewMode
    
    func sortedPapers(_ unsortedPapers: [Paper], inverse: Bool) -> [Paper] {
        var firstAuthors: [String] {
            var firsts: [String] = []
            for paper in unsortedPapers {
                firsts.append(paper.authors
                    .sorted(by: {$0.timestamp < $1.timestamp})
                    .map({$0.name})
                    .first!
                )
            }
            return firsts
        }
        
        switch sortOption {
        case .title:
            if inverse {
                return unsortedPapers.sorted { $1.title < $0.title }
            } else {
                return unsortedPapers.sorted { $0.title < $1.title }
            }
        case .dateAdded:
            if inverse {
                return unsortedPapers.sorted { $1.dateAdded > $0.dateAdded }
            } else {
                return unsortedPapers.sorted { $0.dateAdded > $1.dateAdded }
            }
        case .year:
            if inverse {
                return unsortedPapers.sorted { $0.year < $1.year }
            } else {
                return unsortedPapers.sorted { $1.year < $0.year }
            }
        case .author:
            if inverse {
                return unsortedPapers//.sorted(using: Comparable)
            } else {
                return unsortedPapers//.sorted(using: firstAuthors.reversed())
            }
            
        }
    }
    
    var body: some View {
        List(sortedPapers(papers, inverse: inverseSort), selection: $navigationManager.selectedPaper) { paper in
            PaperView(paper: paper, category: category, paperViewMode: paperViewMode)
                .tag(paper)
        }
        .navigationTitle(navigationManager.selectedCategory?.title() ?? "")
        .navigationSubtitle(navigationManager.selectedPaper?.title ?? "")
        .safeAreaBar(edge: .top)  {
            PaperListViewInset(sortOption: $sortOption, inverseSort: $inverseSort)
        }
    }
    
}


struct PaperListViewInset: View {
    @Binding var sortOption: SortOption
    @Binding var inverseSort: Bool
    
    var body: some View {
        HStack {
            Picker("Sort by", selection: $sortOption) {
                Text("Title").tag(SortOption.title)
                Text("Date Added").tag(SortOption.dateAdded)
                Text("Publication Date").tag(SortOption.year)
                //Text("First Author").tag(SortOption.author)
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            
            Spacer()
            
            Button {
                inverseSort.toggle()
            } label: {
                Image(systemName: inverseSort ? "text.line.last.and.arrowtriangle.forward" :"text.line.first.and.arrowtriangle.forward")
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.horizontal, 10)
            .buttonStyle(.accessoryBar)
            .foregroundStyle(inverseSort ? Color.accentColor : .primary)
            
            
        }
        .frame(alignment: .leading)
        //.background(.ultraThinMaterial)
    }
}
