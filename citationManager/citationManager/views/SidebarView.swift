//
//  SidebarView.swift
//  citationManager
//
//  Created by Jort Boxelaar on 17/01/2024.
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) var context
    @EnvironmentObject var navigationStateManager: NavigationStateManager
    
    @Query(sort: \Collection.dateAdded, animation: .default) var collections: [Collection]
    @Query(sort: \Tag.title, animation: .default) var tags: [Tag]
    
    @Query var papers: [Paper]
    
    func Count(_ category: Category) -> Int {
        switch category {
        case .all:
            return papers.count
        case .unread:
            return papers.filter({!$0.read}).count
        case .read:
            return papers.filter({$0.read}).count
        case .favourites:
            return papers.filter({$0.favourite}).count
        case .authors:
            return 0
        case .keywords:
            return 0
        case .objects:
            return 0
        case .readingList:
            return papers.filter({$0.inReadingList}).count
        case .list(let PaperGroup):
            return PaperGroup.papers.count
        case .tags(let PaperGroup):
            return PaperGroup.papers.count
        }
    }
    
    var body: some View {
        List(selection: $navigationStateManager.selectedCategory) {
            Section("Library") {
                ForEach(Category.allCases) { category in
                    Group {
                        Label(category.title(), systemImage: category.iconName)
                            .badge(Count(category))
                    }.tag(category)
                }
            }
            
            Section("Identifiers") {
                Group {
                    Label(Category.authors.title(), systemImage: Category.authors.iconName)
                }.tag(Category.authors)
                
                Group {
                    Label(Category.keywords.title(), systemImage: Category.keywords.iconName)
                }.tag(Category.keywords)
                
                Group {
                    Label(Category.objects.title(), systemImage: Category.objects.iconName)
                }.tag(Category.objects)
            }
            
            Section("Collections") {
                ForEach(collections) { collection in
                    @Bindable var collection = collection
                    HStack{
                        Image(systemName: "tray.2").foregroundStyle(.primary)
                        TextField("New Collection", text: $collection.title)
                            .badge(collection.papers.count)
                    }
                    .tag(Category.list(collection))
                    .contextMenu {
                        Button("Delete Collection") { context.delete(collection) }
                    }
                }
            }
            
            
            Section("Tags") {
                DisclosureGroup {
                    ForEach(tags) { tag in
                        @Bindable var tag = tag
                        HStack{
                            Image(systemName: "number").foregroundStyle(.primary)
                            TextField("New Tag", text: $tag.title)
                                .badge(tag.paperId.count)
                        }
                        .tag(Category.tags(tag))
                        .contextMenu {
                            Button("Delete Tag") { context.delete(tag) }
                        }
                    }
                } label: {
                    Label("Tags", systemImage: "tag")
                }
            }
            
        }
        .safeAreaInset(edge: .bottom)  {
            SidebarInsetView()
        }
    }
}



//#Preview {
//    SidebarView()
//}
