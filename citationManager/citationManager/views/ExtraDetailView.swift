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
}
/*
struct Detailview_Prieviews: PreviewProvider {
    static var previews: some View {
        DetailView(inspectorIsShown: .constant(false))
            .environmentObject(NavigationStateManager())
    }
}
*/
