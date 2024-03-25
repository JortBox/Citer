//
//  DetailView.swift
//  citationManager
//
//  Created by Jort Boxelaar on 17/01/2024.
//

import SwiftUI
import SwiftData
import PDFKit

struct PdfView: View {
    let paper: Paper
    @Binding var inspectorIsShown: Bool
    
    @EnvironmentObject var navigationManager: NavigationStateManager
    @State private var zoomScaleFactor: CGFloat = 1.0
    @State private var showPdfSearch: Bool = false
    @State private var PdfSearchText: String = ""
    @State private var selectedSearchResult: Int = 1
    
    
    var body: some View {
        let url = paper.docLink!
        
        if let document = PDFDocument(url: url) {
            //let pdfView = PDFView()
            PDFKitRepresentedView(document: document,
                                  zoomScaleFactor: zoomScaleFactor,
                                  searchText: PdfSearchText,
                                  selectedSearchResult: selectedSearchResult
            )
            .safeAreaInset(edge: .top, spacing: 0) {
                if showPdfSearch {
                    PdfSearchView(document: document,
                                  searchText: $PdfSearchText,
                                  showPdfSearch: $showPdfSearch,
                                  selectedSearchResult: $selectedSearchResult
                    )
                }
                    
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                HStack(alignment: .center) {
                    Button(action: {
                        zoomScaleFactor -= 0.5
                    }, label: {
                        Image(systemName: "minus.magnifyingglass")
                    })
                    .buttonStyle(.accessoryBar)
                    
                    Button(action: {
                        zoomScaleFactor += 0.5
                    }, label: {
                        Image(systemName: "plus.magnifyingglass")
                    })
                    .buttonStyle(.accessoryBar)
                    
                    Button {
                        withAnimation{
                            showPdfSearch.toggle()
                        }
                    } label: { }
                        .buttonStyle(.plain)
                        .keyboardShortcut("f")
                }
                .padding(.vertical, 5)
            }
            .toolbar {
                Button {
                    navigationManager.highlightMode = true
                    //ManageHighlights(pdfView, url: url)
                } label: {
                    Image(systemName: "highlighter")
                }
                
                Button {
                    inspectorIsShown.toggle()
                } label: {
                    if inspectorIsShown == true {
                        Label("Toggle Inspector", systemImage: "doc.append.fill.rtl")
                    } else {
                        Label("Toggle Inspector", systemImage: "doc.append.rtl")
                    }
                }
            }
        } else {
            Text("Error: Associated PDF not found!")
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
