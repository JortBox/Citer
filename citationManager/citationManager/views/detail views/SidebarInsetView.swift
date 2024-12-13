//
//  SidebarInsetView.swift
//  Citer
//
//  Created by Jort Boxelaar on 09/12/2024.
//

import SwiftUI

struct SidebarInsetView: View {
    @Environment(\.modelContext) var context
    @Environment(\.openSettings) private var openSettings
    
    var body: some View {
        HStack {
            Button(action: {
                context.insert(Collection(title: "New Collection"))
            }, label: {
                Label("New Collection", systemImage: "plus.circle")
            })
            .buttonStyle(.borderless)
            .foregroundStyle(.accent)
            .padding()
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            Spacer()
            
            Button(action: {
                openSettings()
            }, label: { Image(systemName: "gear") })
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
        }
    }
}
