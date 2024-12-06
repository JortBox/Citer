//
//  AuthorListView.swift
//  Citer
//
//  Created by Jort Boxelaar on 17/02/2024.
//

import SwiftUI
import SwiftData

struct ObjectListView: View {
    @Query var papers: [Paper]
    @EnvironmentObject var navigationManager: NavigationStateManager
    
    let objects: [Object]
    
    var body: some View {
        List(selection: $navigationManager.selectedObject) {
            ForEach(objects.unique(by: {$0.display})) { object in
                let NEDLink = URL(string: "https://ned.ipac.caltech.edu/byname?objname=\(object.name.replacingOccurrences(of: "_", with: "+"))")
                Label(object.display, systemImage: "hurricane")
                    .badge(papers.filter({$0.objects.map({$0.name}).contains(object.name)}).count)
                    .tag(object)
                    .contextMenu {
                        if let link = NEDLink {
                            Link("View on NASA Extragalactic Database (NED)", destination: link)
                                .foregroundStyle(.blue)
                                .frame(alignment: .leading)
                        }
                    }
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .navigationTitle(navigationManager.selectedCategory?.title() ?? "")
        .navigationSubtitle(navigationManager.selectedObject?.display ?? "")
    }
}


    
