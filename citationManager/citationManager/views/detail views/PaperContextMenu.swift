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
    
    var body: some View {
        Button("Open in new Window") { openWindow(id: "Reference", value: paper.id) }
        Divider()
        Button(paper.favourite ? "Remove from Favourites" : "Add to Favourites") { paper.favourite.toggle() }
        Button(paper.read ? "Mark as Unread": "Mark as Read") { paper.read.toggle() }
        Button(paper.inReadingList ? "Remove from Reading List": "Add to Reading List") { paper.inReadingList.toggle() }
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
        Button("Copy Bibcode") { NSPasteboard.general.setString("\(paper.bibcode)" , forType: .string) }
        Divider()
        Button("Info") { openWindow(id: "Info", value: paper.id) }
        if let link = paper.webLink {
            Link("View on ADS", destination: link)
                .foregroundStyle(.blue)
                .frame(alignment: .leading)
        }
        Divider()
        Button("Delete Paper") {
            deletePaper(paper)
        }
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
