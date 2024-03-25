//
//  infoView.swift
//  citationManager
//
//  Created by Jort Boxelaar on 25/01/2024.
//

import SwiftUI
import SwiftData

struct InfoView: View {
    var paperId: UUID
    
    @Query var papers: [Paper]
    @State private var popoverIsPresented: Bool = false
    
    var body: some View {
        let paper: Paper = papers.filter({$0.id == paperId})[0]
        
        List {
            VStack(alignment: .leading) {
                Label {
                    HStack(alignment: .top) {
                        Text("Title:").frame(alignment: .top)
                        Text(paper.title)
                            .foregroundStyle(.secondary)
                    }
                } icon: { Image(systemName: "doc.text").foregroundColor(.primary) }
                Divider()
                Label {
                    HStack(alignment: .top) {
                        Text("Date:")
                        Text(paper.year)
                            .foregroundStyle(.secondary)
                    }
                } icon: { Image(systemName: "calendar").foregroundColor(.primary) }
                Divider()
                Label {
                    HStack(alignment: .top) {
                        Text("Authors:")
                        Text(AuthorList(paper: paper).joined(separator: ","))
                            .foregroundStyle(.secondary)
                    }
                } icon: { Image(systemName: "person.2").foregroundColor(.primary) }
                Divider()
                
                VStack(alignment: .leading) {
                    Label {
                        HStack(alignment: .top) {
                            Text("Tags:")
                            //Text(tags.filter({$0.papers.contains(paper)}).map({"#\($0.title)"}).joined(separator: " "))
                            //    .foregroundStyle(.blue)
                            
                        }
                    } icon: { Image(systemName: "tag").foregroundColor(.primary) }
                    
                    
                    Menu {
                        Button("New Tag") {
                            let newTag = Tag(title: "New Tag")
                            newTag.papers.append(paper)
                            //context.insert(newTag)
                            
                        }
                        Divider()
                        /*
                        ForEach(tags) { tag in
                            Button(action: {
                                if !tag.papers.contains(paper) {
                                    tag.papers.append(paper)
                                } else {
                                    tag.papers.removeAll(where: {$0.bibcode == paper.bibcode})
                                }
                            }, label: {
                                if !tag.papers.contains(paper) {
                                    Text("#\(tag.title)")
                                } else {
                                    Text("✓ #\(tag.title)")
                                }
                            })
                        }
                         */
                    } label: { Label("Add Tag", systemImage: "number") }
                        .menuIndicator(.hidden)
                        .menuStyle(.borderlessButton)
                        .frame(alignment: .trailing)
                     
                        
                    
                }
                Divider()
                
                Label {
                    HStack(alignment: .top) {
                        Text("Added:")
                        Text(paper.dateAdded.formatted(date: .numeric, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                } icon: { Image(systemName: "calendar.badge.plus").foregroundColor(.primary) }
                
                Divider()
                Label {
                    HStack(alignment: .top) {
                        Text("IDs:")
                        VStack(alignment: .leading) {
                            Text("ADS: " + paper.bibcode)
                                .foregroundStyle(.secondary)
                            Text("ArXiv: " + paper.arXivId)
                                .foregroundStyle(.secondary)
                            Text("doi: " + paper.doi)
                                .foregroundStyle(.secondary)
                        }
                    }
                } icon: { Image(systemName: "doc.viewfinder").foregroundColor(.primary) }
                Divider()
                Label {
                    HStack(alignment: .top) {
                        Text("Online:")
                        if let link = paper.webLink {
                            Link(link.absoluteString, destination: link)
                                .foregroundStyle(.blue)
                                .frame(alignment: .leading)
                        } else {
                            Text("Not Availible")
                        }
                    }
                } icon: { Image(systemName: "globe").foregroundColor(.primary) }
                
                Divider()
                Label {
                    HStack(alignment: .top) {
                        Text("Path:")
                        VStack(alignment: .leading) {
                            Text(paper.docLink?.absoluteString ?? "Not Availible")
                                .foregroundStyle(.secondary)
                            
                            if let docLink = paper.docLink, let pdfLink = paper.pdfLink {
                                Button(action: {
                                    Task.detached {
                                        download(url: pdfLink, toFile: URL(filePath: docLink.absoluteString)) { (error) in
                                            if (error != nil) {
                                                print(error!.localizedDescription)
                                            }
                                        }
                                    }
                                }, label: {
                                    Label("Reload PDF", systemImage: "arrow.circlepath")
                                        .foregroundStyle(.primary)
                                })
                                .buttonStyle(.accessoryBar)
                            } else {
                                Label("No PDF Avilible", systemImage: "slash.circle")
                            }
                        }
                    }
                } icon: { Image(systemName: "doc.text.magnifyingglass").foregroundColor(.primary) }
                
                Divider()
                
                Label {
                    HStack(alignment: .top) {
                        Text("Number of references:")
                        Text(paper.bibliography.count.description)
                            .foregroundStyle(.secondary)
                    }
                } icon: { Image(systemName: "square.3.stack.3d").foregroundColor(.primary) }
                
                Divider()
                
                Label {
                    HStack(alignment: .top) {
                        Text("Keywords:")
                        if !paper.keywords.isEmpty {
                            VStack(alignment: .leading) {
                                ForEach(paper.keywords) { keyword in
                                    Text("- \(keyword.full)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } icon: { Image(systemName: "key.viewfinder").foregroundColor(.primary) }
                
                Divider()
                
                Label {
                    HStack(alignment: .top) {
                        Text("Abstract:")
                        Text(paper.abstract)
                            .foregroundStyle(.secondary)
                    }
                } icon: { Image(systemName: "info.bubble.rtl").foregroundColor(.primary) }
                
            }
            .textSelection(.enabled)
        }
    }
    
    func AuthorList(paper: Paper) -> [String] {
        var authorList: [String] = []
        
        for author in paper.authors.sorted(by: {$0.timestamp < $1.timestamp}) {
            authorList.append(author.name)
        }
        return authorList
    }
}

//#Preview {
//    InfoView()
//}
