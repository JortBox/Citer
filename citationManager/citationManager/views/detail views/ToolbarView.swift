//
//  ToolbarView.swift
//  Citer
//
//  Created by Jort Boxelaar on 25/02/2024.
//

import SwiftUI
import SwiftData

struct ToolbarView: View {
    @Environment(\.modelContext) var context
    @Environment(\.openWindow) var openWindow
    @Query(sort: \Paper.title, animation: .default) var papers: [Paper]
    
    @EnvironmentObject var navigationManager: NavigationStateManager
    
    @Binding var inspectorIsShown: Bool
    @State private var popoverIsShown: Bool = false
    @State private var addPaperLink: String = ""

    var body: some View {
        HStack{
            Button(action: {
                self.popoverIsShown.toggle()
            }, label: {
                Label("Add Paper", systemImage: "doc.badge.plus")
                    .foregroundStyle(popoverIsShown ? .accent : .secondary)
            })
            .buttonStyle(.accessoryBar)
            .popover(isPresented: $popoverIsShown, arrowEdge: .bottom) {
                VStack(alignment: .trailing) {
                    TextField("Add paper with ADS bibcode", text: $addPaperLink)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                        .padding()
                        .onSubmit {
                            addPaperLink = AddPaper(paperId: addPaperLink)
                            addPaperLink = ""
                            popoverIsShown.toggle()
                        }
                    
                    Text("Powered by the SAO/NASA ADS API")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.top, -5)
                    
                    Button(action: {
                        addPaperLink = ""
                        popoverIsShown.toggle()
                        openWindow(id: "Form")
                        
                    }, label: {
                        Label("Add manually", systemImage: "plus")
                            .font(.footnote)
                    })
                    .buttonStyle(.accessoryBarAction)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        
        Button( action: {
            if let paper = navigationManager.selectedPaper {
                paper.favourite.toggle()
            }
        }, label: {
            if let paper = navigationManager.selectedPaper {
                Label(paper.favourite ? "Remove From Favourites" : "Add To Favourites", systemImage: paper.favourite ? "star.fill" : "star")
            } else {
                Label("Add To Favourites", systemImage: "star")
            }
        })
        .disabled(navigationManager.selectedPaper == nil)
        
        Spacer()
        
        if navigationManager.selectedPaper == nil && navigationManager.selectedCategory != .authors && navigationManager.selectedCategory != .keywords {
            Button { } label: {
                Image(systemName: "highlighter")
            }
            .disabled(true)
            
            Button {
                inspectorIsShown.toggle()
            } label: {
                Label("Toggle Inspector", systemImage: inspectorIsShown ? "doc.append.fill.rtl" : "doc.append.rtl")
            }
            .disabled(true)
        }
    }
    
    func AddPaper(paperId: String) -> String {
        let container  = context.container
        if papers.map({$0.bibcode}).contains(paperId) {
            return String("Paper Already In Library")
        }
        
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
        return String("Paper Added")
    }
    
}
