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
    @Binding var searchTerm: String
    
    var body: some View {
        let filteredObjects: [Object] = {
            if !searchTerm.isEmpty {
                return objects.filter({$0.display.localizedCaseInsensitiveContains(searchTerm)})
            } else {
                return objects
            }
        }()
        
        List(filteredObjects.unique(by: {$0.display}), selection: $navigationManager.selectedObject) { object in
            let SIMBADLink = URL(string: "https://simbad.u-strasbg.fr/simbad/sim-basic?Ident=\(object.name.replacingOccurrences(of: "_", with: " "))")
            let NEDLink = URL(string: "https://ned.ipac.caltech.edu/byname?objname=\(object.name.replacingOccurrences(of: "_", with: "+"))")
            Label(object.display, systemImage: "hurricane")
                //.badge(papers.filter({$0.objects.map({$0.name}).contains(object.name)}).count)
                .tag(object)
                .contextMenu {
                    if let link1 = SIMBADLink {
                        Link("View on SIMBAD (Strasbourg)", destination: link1)
                            .foregroundStyle(.blue)
                            .frame(alignment: .leading)
                    }
                    if let link2 = NEDLink {
                        Link("View on NASA Extragalactic Database (NED)", destination: link2)
                            .foregroundStyle(.blue)
                            .frame(alignment: .leading)
                    }
                }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .navigationTitle(navigationManager.selectedCategory?.title() ?? "")
        .navigationSubtitle(navigationManager.selectedObject?.display ?? "")
    }
}


    
