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
    @Query var allPapers: [Paper]
    
    let paper: Paper
    @Binding var inspectorIsShown: Bool
    
    @EnvironmentObject var navigationManager: NavigationStateManager
    @State private var zoomScaleFactor: CGFloat = 1.0
    @State private var showPdfSearch: Bool = false
    @State private var PdfSearchText: String = ""
    @State private var selectedSearchResult: Int = 1
    
    @State private var showPopup = false
    @State private var showNote = false
    @State private var referenceMatches: [Reference] = []
    @State private var isEditingNote: Bool = false
    @State private var currentNote: String = ""
    @State private var isHovering: Bool = false
    
    
    var body: some View {
        let url = paper.docLink!
        
        
        if let document = PDFDocument(url: url) {
            PDFKitRepresentedView(document: document,
                                  zoomScaleFactor: zoomScaleFactor,
                                  searchText: PdfSearchText,
                                  selectedSearchResult: selectedSearchResult
            )
            .onReceive(NotificationCenter.default.publisher(for: .didClickPDFLink)) { note in
                if let annotation = note.object as? PDFAnnotation {
                    if annotation.destination != nil {
                        referenceMatches = FindAnnotadedPaper(document, annotation: annotation)
                    }
                    showPopup = true
                }
            }
            .popover(isPresented: $showPopup, attachmentAnchor: .point(UnitPoint(x: 0.05, y: 0.5)), arrowEdge: .leading) {
                if referenceMatches.count != 0 {
                    VStack(alignment: .leading) {
                        ForEach(referenceMatches, id: \.id) { bibitem in
                            var asociatedPaper: Paper? {
                                let paper = allPapers.filter({$0.bibcode == bibitem.bibcode})
                                if paper.count == 0 {
                                    return nil
                                } else {
                                    return paper.first
                                }
                            }
                            ReferenceView(reference: bibitem, asociatedPaper: asociatedPaper)
                                .padding()
                                .frame(width: 400)
                        }
                    }
                } else {
                    Text("No matching references found.")
                        .padding()
                        .frame(width: 400)
                        .font(.headline)
                }
            }
            .safeAreaBar(edge: .top, spacing: 0) {
                if showPdfSearch {
                    PdfSearchView(document: document,
                                  searchText: $PdfSearchText,
                                  showPdfSearch: $showPdfSearch,
                                  selectedSearchResult: $selectedSearchResult
                    )
                }
            }
            .overlay(alignment: .bottomLeading) {
                Button(action: {
                    // Your button action here
                    showNote.toggle()
                    //print("Button clicked")
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "text.pad.header")
                        
                        if isHovering {
                            Text("Notes")
                                .transition(.move(edge: .leading).combined(with: .blurReplace))
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.yellow.opacity(0.4))
                            .glassEffect()
                    )
                    .animation(.easeInOut(duration: 0.25), value: isHovering)
                }
                .padding()
                .controlSize(.extraLarge)
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isHovering = hovering
                    }
                }
                .popover(isPresented: $showNote, arrowEdge: .leading) {
                    PaperNoteView(paper: paper, isEditing: $isEditingNote, currentNote: $currentNote)
                }
                /*
                 Button(action: {
                 showNote.toggle()
                 }, label: {
                 Image(systemName: "text.pad.header")
                 })
                 .buttonStyle(.glass)
                 .buttonBorderShape(.circle)
                 .tint(.yellow)
                 .controlSize(.extraLarge)
                 .padding()
                 .popover(isPresented: $showNote, arrowEdge: .bottom) {
                 PaperNoteView(paper: paper, isEditing: $isEditingNote, currentNote: $currentNote)
                 }
                 */
            }
            .overlay(alignment: .bottom) {
                HStack(alignment: .center) {
                    Button(action: {
                        zoomScaleFactor -= 0.5
                    }, label: {
                        Image(systemName: "minus.magnifyingglass")
                    })
                    .buttonStyle(.glass)
                    
                    Button(action: {
                        zoomScaleFactor += 0.5
                    }, label: {
                        Image(systemName: "plus.magnifyingglass")
                    })
                    .buttonStyle(.glass)
                    
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
                Button( action: {
                    paper.favourite.toggle()
                }, label: {
                    Label(paper.favourite ? "Remove From Favourites" : "Add To Favourites", systemImage: paper.favourite ? "star.fill" : "star")
                })
                
                Button {
                    navigationManager.highlightMode = true
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
            ErrorPaperView()
        }
    }
    
    func FindAnnotadedPaper(_ document: PDFDocument, annotation: PDFAnnotation) -> [Reference] {
        var matches: [Reference] = []
        var nameSurnameSeperated: Bool = true
        
        let destpage = annotation.destination!.page
        let location = annotation.destination!.point
        let selection = destpage?.selection(for: CGRect(x: location.x - 5, y: location.y - 10, width: 1000, height: 10))
        
        //print("clicked reerence")
        //print("string \(selection?.string)")
        
        if let result = selection?.string {
            let componentList = result.split(separator: ",")
            let firstAuthor = componentList.first ?? "Unknown Author"
            if firstAuthor.contains(".") {
                nameSurnameSeperated = false
            } else {
                nameSurnameSeperated = true
            }
            //print("components: \(componentList)")
            // search first author in reference list
            for reference in paper.bibliography {
                //print("referece: \(reference.authorList.split(separator: ",").first!)")
                if firstAuthor.localizedCaseInsensitiveContains(reference.authorList.split(separator: ",").first!) {
                    matches.append(reference)
                }
            }
            
            // return matches if one has been found
            if matches.count <= 1 { return matches }
            
            // expand search to year
            let filtered_matches = matches.filter( { result.contains($0.year) } )
            if filtered_matches.count >= 1 { return filtered_matches }
            else if filtered_matches.count == 0 { return matches }
            /*
            // select second author in list
            if nameSurnameSeperated && componentList.count > 2 {
                let secondAuthor = componentList[2]
            } else if !nameSurnameSeperated && componentList.count > 1{
                let secondAuthor = componentList[1]
            } else {
                return matches
            }
             */
            
            for reference in paper.bibliography {
                let authorList = reference.authorList.split(separator: ",")
                print(authorList)
                //if secondAuthor.localizedCaseInsensitiveContains(reference.authorList.split(separator: ",").first!) {
                //
                //}
            }
            
            
            
            
 
        }
        return matches
    }
}

