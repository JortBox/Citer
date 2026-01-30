//
//  PdfUtilites.swift
//  Citer
//
//  Created by Jort Boxelaar on 15/02/2024.
//

import Foundation
import PDFKit
import SwiftUI

func ManageHighlights(_ pdfView: PDFView, url: URL) {
    //let url = (pdfView.document?.documentURL)!
    guard let selections = pdfView.currentSelection?.selectionsByLine()
    else { return }
    
    selections.forEach({ selection in
        selection.pages.forEach({ page in
            let selRect = selection.bounds(for: page)
            let rect = NSRect(x: selRect.minX,
                              y: selRect.minY - 2,
                              width: selRect.width,
                              height: selRect.height + 2
            )
            let highlight = PDFAnnotation(bounds: rect, forType: .highlight, withProperties: nil)
            highlight.color = .yellow.withAlphaComponent(0.8)
            
            let removedHighlight = checkForExistingHighlight(page: page, highlight: highlight)
            if !removedHighlight {
                page.addAnnotation(highlight)
            }
        })
    })
    pdfView.document?.write(to: url)
}

func checkForExistingHighlight(page: PDFPage, highlight: PDFAnnotation) -> Bool {
    for annotation in page.annotations {
        if annotation.type == "Highlight" {
            if (Round(annotation.bounds.minY) == Round(highlight.bounds.minY)) {
                if (Round(annotation.bounds.minX) >= Round(highlight.bounds.minX) && Round(annotation.bounds.maxX) <= Round(highlight.bounds.maxX)) {
                    //print("must remove: \(annotation)")
                    page.removeAnnotation(annotation)
                    return true
                }
                else if (Round(annotation.bounds.minX) <= Round(highlight.bounds.minX) && Round(annotation.bounds.maxX) >= Round(highlight.bounds.maxX)) {
                    return true
                }
            }
        }
    }
    return false
    
    func Round(_ number: CGFloat, significance: Int = 1) -> Double {
        return Double(round(number * 10) / 10)
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


func convertPDFToImage(pdfURL: URL) -> NSImage? {
    guard let pdfDocument = PDFDocument(url: pdfURL)
    else { return nil }
    
    guard let page = pdfDocument.page(at: 0) 
    else { return nil }
    
    let pdfSize = page.bounds(for: .mediaBox)
    let imagesize = NSSize(width: pdfSize.width/2, height: pdfSize.height/2)
    let image = page.thumbnail(of: imagesize, for: .mediaBox)
    
    return image
}
