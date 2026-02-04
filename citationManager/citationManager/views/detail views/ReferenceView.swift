//
//  ReferenceView.swift
//  citationManager
//
//  Created by Jort Boxelaar on 19/01/2024.
//

import SwiftUI
import SwiftData

struct ReferenceView: View {
    @Environment(\.modelContext) var context
    @Environment(\.openURL) var openURL
    @Environment(\.openWindow) var openWindow
    
    let reference: Reference
    let asociatedPaper: Paper?
    @State private var inLibrary: Bool =  false
    
    var body: some View {
        Label {
            VStack(alignment: .leading) {
                if reference.authors.isEmpty {
                    Text("Author Not Availible")
                        .font(.body)
                        .lineLimit(2)
                } else {
                    Text(AuthorList(paper: reference).joined(separator: ", "))
                        .font(.body)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if reference.year.isEmpty {
                    Text("Date Not Availible" )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                } else {
                    Text(reference.year )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                
                Text(reference.title)
                    .font(.subheadline)
                    .textSelection(.enabled)
                
                Spacer()
                HStack {
                    if !reference.bibcode.isEmpty {
                        if let link = URL(string: "https://ui.adsabs.harvard.edu/abs/" + reference.bibcode) {
                            Button(action: {
                                openURL(link)
                            }, label: {
                                Label("ADS", systemImage: "arrow.up.right.square")
                                    .font(.footnote)
                                    .foregroundStyle(.blue)
                            })
                            .buttonStyle(.automatic)
                            
                        } else {
                            Label("SAO/NASA ADS", systemImage: "exclamationmark.triangle")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                        
                        Button(
                            action: {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString("\(reference.citation)", forType: .string)
                            }, label: {
                                Label("BibTex Citation", systemImage: "document.on.document")
                                    .font(.footnote)
                                    .foregroundStyle(.foreground)
                            }
                        ).buttonStyle(.automatic)
                       
                        if asociatedPaper != nil {
                            Button(action: {
                                openWindow(id: "Reference", value: asociatedPaper!.id)
                            }, label: {
                                Label("Open In New Tab", systemImage: "plus.square.on.square")
                                    .font(.footnote)
                            })
                            .buttonStyle(.glassProminent)
                            //.buttonStyle(CustomAccentButton())
                            
                        } else {
                            Button(action: {
                                AddPaper(paperId: reference.bibcode)
                            }, label: {
                                Label("Add to Library", systemImage: "tray.and.arrow.down").font(.footnote)
                            })
                            .buttonStyle(.automatic)
                            //.buttonStyle(CustomButtonDark())
                        }

                    } else {
                        Label("ADS: \(reference.bibcode)", systemImage: "doc.viewfinder")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                            .textSelection(.enabled)
                    }
                }
                Spacer()
            }
        } icon: {
            if asociatedPaper != nil {
                Image(systemName: "quote.bubble.fill.rtl").foregroundColor(.accentColor)
            } else {
                Image(systemName: "quote.bubble.rtl").foregroundColor(.primary)
            }
        }
    }
    
    func AuthorList(paper: Reference) -> [String] {
        var authorList: [String] = []
        
        for author in paper.authors {
            authorList.append(author)
        }
        return authorList
    }
    
    func AddPaper(paperId: String) {
        let container  = context.container
        
        do{
            try context.save()
            print("context saved 1")
        } catch { print("context failed to save") }

        Task.detached {
            let handler = DataHandler(modelContainer: container)
            let paper = try await handler.newItem(paperId: paperId)
            let references = await ReferencesQuery(paperIds: paper.referenceIds)
            
            try await handler.updateItem(paper, bibliography: references)
        }
    }
}

struct CustomButtonDark: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
            .background(configuration.isPressed ? .tertiary : .quinary)
            .foregroundStyle(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct CustomAccentButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
            .background(configuration.isPressed ? .gray : .accent)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}


/*
struct ReferenceView_Previews: PreviewProvider {
    static var previews: some View {
        ReferenceView(reference: PaperData.example())
            .environmentObject(ModelDataManager())
    }
}
*/
