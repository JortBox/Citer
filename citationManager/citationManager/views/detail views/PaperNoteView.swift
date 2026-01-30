//
//  PaperNoteView.swift
//  Citer
//
//  Created by Jort Boxelaar on 04/11/2025.
//

import SwiftUI



struct PaperNoteView: View {
    let paper: Paper
    @Binding var isEditing: Bool
    @Binding var currentNote: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("Notes")
                    .font(.headline)
                Spacer()
                Button(action: {
                    if isEditing {
                        paper.notes = currentNote
                    } else {
                        currentNote = paper.notes
                    }
                    isEditing.toggle()
                }, label: {
                    Label(isEditing ? "Done" : "Edit", systemImage: isEditing ? "checkmark" : "pencil")
                })
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .keyboardShortcut(.defaultAction)
            }
            Spacer()
            
            if !isEditing {
                ScrollView {
                    Text(paper.notes)
                        .frame(alignment: .topLeading)
                }
                .frame(minWidth: 300, idealWidth: 400, idealHeight: 600)
                .presentationCompactAdaptation(.popover)
            } else {
                TextEditor(text: $currentNote)
                    .frame(minWidth: 300, idealWidth: 400, idealHeight: 600)
                    .presentationCompactAdaptation(.popover)
            }
            HStack {
                Spacer()
                Button(action: {
                    if !isEditing {
                        paper.notes = ""
                        currentNote = ""
                    }
                }, label: {
                    Image(systemName: "trash")
                        .padding(5)
                })
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .tint(.red)
            }
            
        }
        .padding()
    }
}


