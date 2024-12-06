//
//  DetailView.swift
//  citationManager
//
//  Created by Jort Boxelaar on 17/01/2024.
//

import SwiftUI
import SwiftData
import PDFKit

struct ExtraDetailView: View {
    @StateObject var navigationManager = NavigationStateManager()
    @State private var inspectorIsShown: Bool = false
    @State private var zoomScaleFactor: CGFloat = 1.0
    @State private var showPdfSearch: Bool = false
    @State private var PdfSearchText: String = ""
    @State private var selectedSearchResult: Int = 1
    
    let paperId: UUID
    var paper: Paper? = nil
    @Query var papers: [Paper]
    
    var body: some View {
        var paper: Paper? {
            for item in papers {
                if item.id == paperId {
                    return item
                }
            }
            return nil
        }
        
        if (paper != nil) {
            PdfView(paper: paper!, inspectorIsShown: $inspectorIsShown)
                .environmentObject(navigationManager)
                .navigationTitle(paper!.title)
                .navigationSubtitle(ShortAuthorList(paper: paper!))
                .inspector(isPresented: $inspectorIsShown) {
                    InspectorView(paper: paper!)
                }
                .onAppear { paper!.new = false }
            
        } else {
            Image(systemName: "doc.questionmark")
                .foregroundStyle(.primary)
                //.imageScale(.large)
                .font(.system(size: 40))
                .padding()
            Text("Error while loading paper")
        }
    }
    
    func ShortAuthorList(paper: Paper) -> String {
        let allAuthors: [String] = paper.authors.sorted(by: {$0.timestamp < $1.timestamp}).map({$0.name})
        
        if allAuthors.count == 1 {
            return allAuthors[0]
        }
        else if paper.authors.count == 2 {
            return allAuthors[0] + " & " + allAuthors[1]
        }
        else {
            return allAuthors[0] + " et al."
            }
    }
}
