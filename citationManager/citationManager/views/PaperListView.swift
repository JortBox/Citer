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
    var paperViewMode: PaperViewMode
    
    func sortedPapers(_ unsortedPapers: [Paper]) -> [Paper] {
        switch sortOption {
        case .title:
            return unsortedPapers.sorted { $0.title < $1.title }
        case .dateAdded:
            return unsortedPapers.sorted { $0.dateAdded > $1.dateAdded }
        case .year:
            return unsortedPapers.sorted { $0.year > $1.year }
        }
    }
    
    var body: some View {
        List(sortedPapers(papers), selection: $navigationManager.selectedPaper
        ) { paper in
            PaperView(paper: paper, category: category, paperViewMode: paperViewMode)
                .tag(paper)
        }
        .navigationTitle(navigationManager.selectedCategory?.title() ?? "")
        .navigationSubtitle(navigationManager.selectedPaper?.title ?? "")
        .safeAreaInset(edge: .top)  {
            Picker("Sort By", selection: $sortOption) {
                Text("Title").tag(SortOption.title)
                Text("Date Added").tag(SortOption.dateAdded)
                Text("Publication Date").tag(SortOption.year)
            }
            .pickerStyle(.menu)
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .frame(alignment: .leading)
            .background(.ultraThinMaterial)
        }
    }
}

