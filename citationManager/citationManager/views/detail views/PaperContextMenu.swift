//
//  PaperContextMenu.swift
//  Citer
//
//  Created by Jort Boxelaar on 17/02/2024.
//

import SwiftUI
import SwiftData

struct PaperContextMenu: View {
    let paper: Paper
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.modelContext) var context
    @EnvironmentObject var navigationManager: NavigationStateManager
    @Query var collections: [Collection]
    @Query var tags: [Tag]
    
    @Binding var showDialog: Bool
    var confirmation: Bool = false
    
    var body: some View {
        Button (action: { openWindow(id: "Reference", value: paper.id) },
                label: {Label("Open In New Window", systemImage: "plus.rectangle.on.rectangle")}
        )
        Divider()
        Button (action: {paper.favourite.toggle()},
                label: {Label(paper.favourite ? "Remove from Favourites" : "Add to Favourites",
                              systemImage: paper.favourite ? "star.fill" : "star")}
        )
        Button (action: {paper.read.toggle()},
                label: {Label(paper.read ? "Mark as Unread": "Mark as Read", systemImage: "checkmark.seal.text.page")}
        )
        Button (action: {paper.inReadingList.toggle()},
                label: {Label(paper.inReadingList ? "Remove from Reading List": "Add to Reading List",
                              systemImage: paper.inReadingList ? "eyeglasses.slash" :"eyeglasses")}
        )
        Menu("Add to Collection") {
            ForEach(collections) { collection in
                Button(action: {
                    if !collection.papers.contains(paper) {
                        collection.papers.append(paper)
                    } else {
                        collection.papers.removeAll(where: {$0.bibcode == paper.bibcode})
                    }
                }, label: {
                    if !collection.papers.contains(paper) {
                        Text(collection.title)
                    } else {
                        Text("✓ " + collection.title)
                    }
                })
            }
        }
        
        Menu("Tags") {
            Button("New Tag") {
                let newTag = Tag(title: "New Tag")
                newTag.paperId.append(paper.bibcode)
                context.insert(newTag)
                
            }
            Divider()
            ForEach(tags) { tag in
                Button(action: {
                    if !tag.paperId.contains(paper.bibcode) {
                        tag.paperId.append(paper.bibcode)
                    } else {
                        tag.paperId.removeAll(where: {$0 == paper.bibcode})
                    }
                }, label: {
                    Text(tag.paperId.contains(paper.bibcode) ? "✓ #\(tag.title)" : "#\(tag.title)")
                })
            }
        }
        Divider()
        Button (action: {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString("\(paper.bibcode)", forType: .string)
        },label: {Label("Copy Bibcode", systemImage: "document.on.document")}
        )
        Button (action: {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString("\(paper.citation)", forType: .string)
        },label: {Label("Copy BibTex Citation", systemImage: "curlybraces")}
        )
        Divider()
        Button (action: {openWindow(id: "Info", value: paper.id)},
                label: {Label("Info", systemImage: "info.circle")}
        )
        
        if let link = paper.webLink {
            Link(destination: link, label: {Label("View on ADS", systemImage: "arrow.up.right.square")})
                .foregroundStyle(.blue)
                .frame(alignment: .leading)
        }
        Divider()
        Button (action: {
            if confirmation {
                showDialog = true
            } else {
                deletePaper(paper)
            }
        }, label: {Label("Delete Paper", systemImage: "trash")}
        )
    }
    
    
    func deletePaper(_ paper: Paper, fromCollection: Collection? = nil, fromTag: Tag? = nil) {
        
        if let collection = fromCollection {
            collection.papers.removeAll(where: {$0.bibcode == paper.bibcode})
        }
        
        if let tag = fromTag {
            tag.paperId.removeAll(where: {$0 == paper.bibcode})
        }

        if fromCollection == nil && fromTag == nil{
            for collection in collections {
                collection.papers.removeAll(where: {$0.bibcode == paper.bibcode})
            }
            
            for tag in tags {
                tag.paperId.removeAll(where: {$0 == paper.bibcode})
            }
            
            navigationManager.selectedAuthor = nil
            navigationManager.selectedKeyword = nil
            navigationManager.selectedPaper = nil
            context.delete(paper)
        }
        

    }
}
