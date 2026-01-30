//
//  DetailView.swift
//  Citer
//
//  Created by Jort Boxelaar on 18/02/2024.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    
    enum ViewMode: String, CaseIterable, Identifiable {
        var id: Self { self }
        case list
        case gallery
    }
    
    @EnvironmentObject var navigationManager: NavigationStateManager
    @Query(sort: \Paper.title, animation: .default) var papers: [Paper]
    
    @State private var sortOption: SortOption = .title
    @State private var invertSort: Bool = false
    @State private var inspectorTab: tabSelection = .bibliography
    @Binding var inspectorIsShown: Bool
    @SceneStorage("viewMode") private var mode: ViewMode = .gallery

    var body: some View {
        if let category = navigationManager.selectedCategory {
            switch category {
            case .all, .read, .unread, .favourites, .readingList, .list(_), .tags(_):
                if let paper = navigationManager.selectedPaper {
                    PdfView(paper: paper, inspectorIsShown: $inspectorIsShown)
                        .inspector(isPresented: $inspectorIsShown) {
                            InspectorView(paper: paper, inspectorTab: $inspectorTab)
                        }
                        .onAppear { paper.new = false }
                } else { EmptyPaperView() }
                
                
                case .authors:
                    if let author = navigationManager.selectedAuthor {
                        let papersToPass = papers
                            .filter({$0.authors.map({$0.name}).contains(author.name)})
                            .sorted(by: {$0.title < $1.title})
                        
                        Group {
                            switch mode {
                            case .list:
                                PaperListView(papers: papersToPass,
                                              category: .all,
                                              sortOption: $sortOption,
                                              inverseSort: $invertSort,
                                              paperViewMode: .large)
                            case .gallery:
                                TileView(papers: papersToPass)
                            }
                        }
                        .toolbar {
                            Spacer()
                            DisplayModePicker(mode: $mode)
                        }
                    }
                
                case .keywords:
                    if let keyword = navigationManager.selectedKeyword {
                        let papersToPass = papers
                            .filter({$0.keywords.map({$0.full}).contains(keyword.full)})
                            .sorted(by: {$0.title < $1.title})
                        
                        Group {
                            switch mode {
                            case .list:
                                PaperListView(papers: papersToPass,
                                              category: .all,
                                              sortOption: $sortOption,
                                              inverseSort: $invertSort,
                                              paperViewMode: .large)
                            case .gallery:
                                TileView(papers: papersToPass)
                            }
                        }
                        .toolbar {
                            Spacer()
                            DisplayModePicker(mode: $mode)
                        }
                    }
                
            case .objects:
                if let object = navigationManager.selectedObject {
                    let papersToPass = papers
                        .filter({$0.objects.map({$0.name}).contains(object.name)})
                        .sorted(by: {$0.title < $1.title})
                    
                    Group {
                        switch mode {
                        case .list:
                            PaperListView(papers: papersToPass,
                                          category: .all,
                                          sortOption: $sortOption,
                                          inverseSort: $invertSort,
                                          paperViewMode: .large)
                        case .gallery:
                            TileView(papers: papersToPass)
                        }
                    }
                    .toolbar {
                        Spacer()
                        DisplayModePicker(mode: $mode)
                    }
                }
            }
        } else { EmptyPaperView() }
    }
}

struct DisplayModePicker: View {
    @Binding var mode: DetailView.ViewMode

    var body: some View {
        Picker("Display Mode", selection: $mode) {
            ForEach(DetailView.ViewMode.allCases) { viewMode in
                viewMode.label
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

extension DetailView.ViewMode {

    var labelContent: (name: String, systemImage: String) {
        switch self {
        case .list:
            return ("List", "list.bullet")
        case .gallery:
            return ("Gallery", "square.grid.2x2")
        }
    }

    var label: some View {
        let content = labelContent
        return Label(content.name, systemImage: content.systemImage)
    }
}
