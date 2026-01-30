//
//  CatalogsView.swift
//  Citer
//
//  Created by Jort Boxelaar on 16/12/2024.
//

import SwiftUI

struct CatalogsView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.openWindow) var openWindow
    
    let paper: Paper
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Catalogs Availible for")
                    .font(.subheadline)
                Text(paper.bibcode)
                    .bold()
                    .font(.subheadline)
            }
            Divider()
            if !paper.catalogs.isEmpty {
                ForEach(paper.catalogs) { catalog in
                    HStack(alignment: .top) {
                        Image(systemName: "server.rack")
                            .foregroundStyle(.accent)
                        
                        VStack(alignment: .leading) {
                            Text(catalog.name)
                                .font(.headline)
                            
                            Text(catalog.link)
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                            
                            HStack {
                                Button {
                                    openWindow(id: "Table", value: catalog.id)
                                } label: {
                                    Label("Fetch Catalog", systemImage: "plus.square.on.square")
                                }
                                    .buttonStyle(CustomButtonDark())
                                
                                if let link = catalog.url {
                                    Button(action: {
                                        openURL(link)
                                    }, label: {
                                        Label("VizieR", systemImage: "globe")
                                            .font(.footnote)
                                            .foregroundStyle(.blue)
                                    })
                                    .buttonStyle(.accessoryBar)
                                    
                                } else {
                                    Label("VizieR", systemImage: "globe")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 15)
                }
            } else { Text("No catalogs available") }
        }
    }
}


