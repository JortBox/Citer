//
//  PdfSearchView.swift
//  Citer
//
//  Created by Jort Boxelaar on 15/02/2024.
//

import SwiftUI
import PDFKit

struct PdfSearchView: View {
    
    let document: PDFDocument
    @Binding var searchText: String
    @Binding var showPdfSearch: Bool
    @Binding var selectedSearchResult: Int
    
    var body: some View {
        var matches: Int {
            if !searchText.isEmpty {
                return document.findString(searchText, withOptions: NSString.CompareOptions.caseInsensitive).count
            }
            return 0
        }
        
        
        HStack {
            Spacer()
            
            if !searchText.isEmpty {
                if matches == 0 { 
                    Text("Not found")
                }
                else if matches == 1 {
                    Text("1 match")
                }
                else {
                    Text("\(selectedSearchResult) of \(matches) matches")
                }
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: searchText) { selectedSearchResult = 1 }
                if !searchText.isEmpty {
                    Button(action: {searchText = ""}, label: {Image(systemName: "multiply.circle.fill")})
                        .buttonStyle(.borderless)
                }
            }
            .frame(width: 200)
            
            Button {
                if selectedSearchResult == 1 {
                    selectedSearchResult = matches
                } else {
                    selectedSearchResult -= 1
                }
            } label: { Image(systemName: "chevron.backward") }
                .buttonStyle(.accessoryBarAction)
            
            Button {
                if selectedSearchResult == matches {
                    selectedSearchResult = 1
                } else {
                    selectedSearchResult += 1
                }
            } label: { Image(systemName: "chevron.forward") }
                .buttonStyle(.accessoryBarAction)
                .keyboardShortcut(.return)
            
            Button("Done") {
                searchText = ""
                withAnimation {
                    showPdfSearch = false
                }
            }
            .keyboardShortcut(.cancelAction)
            .buttonStyle(.accessoryBarAction)
            
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .background(.clear)
    }
}
