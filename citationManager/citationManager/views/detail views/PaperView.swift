//
//  MovieDetailView.swift
//  NavigationStackProject
//
//  Created by Karin Prater on 12.11.22.
//

import SwiftUI
import SwiftData

struct PaperView: View {
    @Environment(\.modelContext) var context
    @Environment(\.openWindow) var openWindow
    @Environment(\.openURL) var openURL
    @EnvironmentObject var navigationManager: NavigationStateManager
    
    @Query(sort: \Collection.title, animation: .default) var collections: [Collection]
    @Query(sort: \Tag.title, animation: .default) var tags: [Tag]

    var paper: Paper
    var category: Category
    var paperViewMode: PaperViewMode
    
    @State private var showFullAbstract: Bool = false
  
    var body: some View {
        Label {
            VStack(alignment: .leading) {
                switch paperViewMode {
                case .small:
                    Text(paper.title.capitalized)
                        .multilineTextAlignment(.leading)
                        .font(.headline)
                        .lineLimit(2)
                
                    Spacer()
                    
                    Text(AuthorList(paper: paper).joined(separator: ", "))
                        .font(.subheadline)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    withAnimation(.easeInOut, {
                        Button(action: {
                            showFullAbstract.toggle()
                        }, label: {
                            Text(paper.abstract)
                                .multilineTextAlignment(.leading)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(showFullAbstract ? .max : 3)
                        })
                        .buttonStyle(.borderless)
                    })
                    
                case .large:
                    Text(paper.title.capitalized)
                        .multilineTextAlignment(.leading)
                        .font(.headline)
                
                    Spacer()
                    
                    Text(AuthorList(paper: paper).joined(separator: ", "))
                        .font(.subheadline)
                        .padding(.trailing, 70)
                    
                    Spacer()
                    
                    Text(paper.abstract)
                        .multilineTextAlignment(.leading)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 70)
                }
                
                
                HStack{
                    Text(paper.year)//.formatted(date: .numeric, time: .omitted) )
                        .lineLimit(1)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                            paper.read.toggle()
                        
                    }, label: {
                        Label(paper.read ? "Read" : "Mark As Read",
                              systemImage: paper.read ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.footnote)
                    })
                    .buttonStyle(CustomButton())
                    
                    if paper.new {
                        Text("New").bold().foregroundStyle(.accent)
                    }
                    
                    if paperViewMode == .large {
                        Button(action: {
                            openWindow(id: "Reference", value: paper.id)
                        }, label: {
                            Label("Open In New Tab", systemImage: "plus.square.on.square")
                                .font(.footnote)
                        })
                        .buttonStyle(CustomButton())
                        
                        Button(action: {
                            openWindow(id: "Info", value: paper.id)
                        }, label: {
                            Label("Info", systemImage: "info.circle")
                                .font(.footnote)
                        })
                        .buttonStyle(CustomButton())
                        
                        if let link = URL(string: "https://ui.adsabs.harvard.edu/abs/" + paper.bibcode) {
                            Button(action: {
                                openURL(link)
                            }, label: {
                                Label("ADS", systemImage: "globe")
                                    .font(.footnote)
                                    .foregroundStyle(.blue)
                            })
                            .buttonStyle(.accessoryBar)
                            
                        } else {
                            Label("SAO/NASA ADS", systemImage: "globe")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                    }
                     
                }
                switch paperViewMode {
                case .small:
                    Spacer()
                case .large:
                    Spacer(minLength: 10)
                }
                Spacer()
            }
        } icon: {
            Image(systemName: paper.favourite ? "star.fill" : "")
            
        }
        .swipeActions {
            switch category {
            case .all, .unread, .read, .favourites, .readingList, .authors, .keywords:
                Button("Delete", systemImage: "trash", role: .destructive) {
                    deletePaper(paper)
                }
            case .list(let collection):
                Button("Remove from Collection", systemImage: "folder.badge.minus") {
                    deletePaper(paper, fromCollection: collection)
                }
            case .tags(let tag):
                Button("Remove Tag", systemImage: "tag.slash.fill") {
                    deletePaper(paper, fromTag: tag)
                }
            }
            
        }
        .contextMenu {
            PaperContextMenu(paper: paper)
        }
    }
    
    func AuthorList(paper: Paper) -> [String] {
        var authorList: [String] = []
        
        for author in paper.authors.sorted(by: {$0.timestamp < $1.timestamp}) {
            authorList.append(author.name)
        }
        return authorList
    }
    
    func deletePaper(_ paper: Paper, fromCollection: Collection? = nil, fromTag: Tag? = nil) {
        
        if let collection = fromCollection {
            collection.papers.removeAll(where: {$0.bibcode == paper.bibcode})
        }
        
        if let tag = fromTag {
            tag.papers.removeAll(where: {$0.bibcode == paper.bibcode})
        }

        if fromCollection == nil && fromTag == nil{
            for collection in collections {
                collection.papers.removeAll(where: {$0.bibcode == paper.bibcode})
            }
            
            for tag in tags {
                tag.papers.removeAll(where: {$0.bibcode == paper.bibcode})
            }
            
            navigationManager.selectedAuthor = nil
            navigationManager.selectedKeyword = nil
            navigationManager.selectedPaper = nil
            context.delete(paper)
        }
        

    }
}

struct CustomButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 3)
            .padding(.horizontal, 5)
            .background(configuration.isPressed ? .quaternary : .quinary)
            .foregroundStyle(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}




/*
struct PaperDataView_Previews: PreviewProvider {
    static var previews: some View {
        PaperDataView(paper: Paper(title: "Avatar", file: "mssselection", authorList: ["Pauli"]))
    }
}
*/
