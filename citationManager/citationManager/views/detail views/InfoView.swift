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
    
    @Environment(\.modelContext) var context
    @Query var papers: [Paper]
    @Query var tags: [Tag]
    @State private var popoverIsPresented: Bool = false
    @State private var tagName: String = ""
    
    var body: some View {
        let paper: Paper = papers.first(where: {$0.id == paperId}) ?? papers.first!
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
                    Text("Tags:")
                    HStack(alignment: .top) {
                        Text(tags.filter({$0.paperId.contains(paper.bibcode)}).map({"#\($0.title)"}).joined(separator: ", "))
                            .foregroundStyle(.blue)
                    }
                } icon: { Image(systemName: "tag").foregroundColor(.primary) }
                
                Button(action: {
                    self.popoverIsPresented.toggle()
                }, label: {
                    Label("Add Tag", systemImage: "plus.circle")
                        .foregroundStyle(popoverIsPresented ? .accent : .secondary)
                })
                .buttonStyle(.accessoryBar)
                .popover(isPresented: $popoverIsPresented, arrowEdge: .bottom) {
                    VStack(alignment: .trailing) {
                        TextField("New Tag", text: $tagName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 250)
                            .padding()
                            .onSubmit {
                                if !tags.map({$0.title}).contains(tagName) {
                                    let newTag = Tag(title: tagName)
                                    newTag.paperId.append(paper.bibcode)
                                    context.insert(newTag)
                                    tagName = ""
                                    popoverIsPresented.toggle()
                                } else {
                                    tagName = "Tag already exists"
                                }
                            }
                    }
                }
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
                    Text("Catalogs:")
                    if !paper.catalogs.isEmpty {
                        VStack(alignment: .leading) {
                            ForEach(paper.catalogs) { catalog in
                                if let url = catalog.url {
                                    Link("\(catalog.name) (VizieR)", destination: url)
                                        .foregroundStyle(.blue)
                                        .frame(alignment: .leading)
                                }
                            }
                        }
                    } else { Text("N/A").foregroundStyle(.secondary) }
                }
            } icon: { Image(systemName: "externaldrive.badge.wifi").foregroundColor(.primary) }
            
            Divider()
            
            VStack(alignment: .leading) {
                Label {
                    HStack(alignment: .top) {
                        Text("BibTex citation:")
                        Button(
                            action: {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString("\(paper.citation)", forType: .string)
                            }, label: {
                                Label {
                                    Text("Copy to Clipboard")
                                } icon: { Image(systemName: "document.on.document").foregroundColor(.primary) }
                            }
                        )
                    }
                } icon: { Image(systemName: "curlybraces").foregroundColor(.primary) }
                
                if paper.citationWarning {
                    Label {
                        Text("BibTex citation maybe incomplete").foregroundStyle(.yellow)
                    } icon: { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.yellow) }
                }
            }
            Divider()
            
            Label {
                HStack(alignment: .top) {
                    Text("Objects:")
                    if !paper.objects.isEmpty {
                        VStack(alignment: .leading) {
                            ForEach(paper.objects.sorted(by: {$0.name < $1.name})) { object in
                                if let NEDLink = URL(string: "https://ned.ipac.caltech.edu/byname?objname=\(object.name.replacingOccurrences(of: "_", with: "+"))") {
                                    Link(object.name, destination: NEDLink)
                                        .foregroundStyle(.blue)
                                        .frame(alignment: .leading)
                                }
                            }
                        }
                    } else { Text("N/A").foregroundStyle(.secondary) }
                }
            } icon: { Image(systemName: "hurricane").foregroundColor(.primary) }
            
            Divider()
            
            Label {
                HStack(alignment: .top) {
                    Text("Abstract:")
                    Text(paper.abstract)
                        .foregroundStyle(.secondary)
                }
            } icon: { Image(systemName: "info.bubble.rtl").foregroundColor(.primary) }
            
            Divider()
            
            Button(
                action: {
                    ReloadInfo(paper: paper)
                }, label: {
                    Label {
                        Text("Reload")
                    } icon: { Image(systemName: "arrow.trianglehead.clockwise.rotate.90").foregroundColor(.primary) }
                }
            )
            
        }
        .textSelection(.enabled)
    }
    
    func AuthorList(paper: Paper) -> [String] {
        var authorList: [String] = []
        
        for author in paper.authors.sorted(by: {$0.timestamp < $1.timestamp}) {
            authorList.append(author.name)
        }
        return authorList
    }
    
    func ReloadInfo(paper: Paper){
        Task.detached{
            let tempPaper = await AdsQuery(paperId: paper.bibcode)
            paper.objects = tempPaper.objects
            paper.abstract = tempPaper.abstract
            paper.citation = tempPaper.citation
            paper.citationWarning = tempPaper.citationWarning
            //paper.catalogs = tempPaper.catalogs
            
            let tempReferences = await ReferencesQuery(paperIds: paper.referenceIds)
            paper.bibliography = tempReferences
        }
        do { try context.save() }
        catch { print("Error saving changes: \(error)") }
        
    }
}

//#Preview {
//    InfoView()
//}
