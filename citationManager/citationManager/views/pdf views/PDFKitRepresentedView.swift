//
//  ContentView.swift
//  citationManager
//
//  Created by Jort Boxelaar on 16/01/2024.
//


import SwiftUI
import PDFKit

struct PDFKitRepresentedView: NSViewRepresentable {
    @EnvironmentObject var navigationManager: NavigationStateManager
    
    let document: PDFDocument
    var zoomScaleFactor: CGFloat
    var searchText: String
    var selectedSearchResult: Int
    var url: URL
    
    init(document: PDFDocument, zoomScaleFactor: CGFloat = 1.0, searchText: String = "", selectedSearchResult: Int = 1) {
        self.document = document
        self.zoomScaleFactor = zoomScaleFactor
        self.searchText = searchText
        self.selectedSearchResult = selectedSearchResult
        self.url = document.documentURL!
    }
    
    func makeNSView(context: NSViewRepresentableContext<PDFKitRepresentedView>) -> PDFKitRepresentedView.NSViewType {
        let pdfView = PDFView()
        pdfView.document = self.document
        pdfView.scaleFactor = zoomScaleFactor
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateNSView(_ pdfView: PDFView, context: NSViewRepresentableContext<PDFKitRepresentedView>) {
        if pdfView.document?.documentURL != self.url {
            pdfView.document = self.document
        }
        
        RemoveSearchResults(pdfView.document!)
        
        if navigationManager.highlightMode {
            ManageHighlights(pdfView, url: self.url)
            navigationManager.highlightMode = false
        }
        
        if !searchText.isEmpty {
            let selectionList = pdfView.document?.findString(searchText, withOptions: NSString.CompareOptions.caseInsensitive)
            var matchCount: Int = 0
            
            selectionList?.forEach({ selection in
                selection.pages.forEach { page in
                    let highlight = PDFAnnotation(bounds: selection.bounds(for: page), forType: .highlight, withProperties: nil)
                    matchCount += 1
                    highlight.endLineStyle = .square
                    highlight.contents = "searchResult"

                    if matchCount == selectedSearchResult {
                        pdfView.go(to: highlight.bounds, on: page)
                        highlight.color = .orange
                    } else {
                        highlight.color = .orange.withAlphaComponent(0.4)
                    }
                    page.addAnnotation(highlight)
                }
            })
        }
        
        if zoomScaleFactor != 1.0 {
            pdfView.scaleFactor = zoomScaleFactor
        }
    }
    
    func RemoveSearchResults(_ document: PDFDocument) {
        for y in stride(from: 0, to: document.pageCount, by: 1) {
            let page: PDFPage = document.page(at: y)!
            
            for annotation in page.annotations {
                if annotation.contents == "searchResult" {
                    page.removeAnnotation(annotation)
                }
            }
        }
    }
}
                               

