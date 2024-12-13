//
//  InspectorView.swift
//  Citer
//
//  Created by Jort Boxelaar on 06/02/2024.
//

import SwiftUI


struct InspectorView: View {

    let paper: Paper
    
    var body: some View {
        /*
            CustomTabView(
                content: [
                    (
                        title: "Bibliography",
                        icon: "doc.append.rtl",
                        view: AnyView (
                            ReferenceListView(paper: paper)
                                .scrollContentBackground(.hidden)
                        ),
                        bordered: false
                    ),
                    (
                        title: "Info",
                        icon: "info.circle",
                        view: AnyView(
                            InfoView(paperId: paper.id)
                                .scrollContentBackground(.hidden)
                        ),
                        bordered: true
                    )
                    ]
            ).inspectorColumnWidth(min: 300, ideal: 400, max: 1000)
         */
        //*
         TabView {
            ReferenceListView(paper: paper)
                .scrollContentBackground(.hidden)
                .tabItem { Text("Bibliography") }
            
            InfoView(paperId: paper.id)
                .scrollContentBackground(.hidden)
                .frame(alignment: .topLeading)
                .tabItem { Text("Paper Info") }
        }.inspectorColumnWidth(min: 300, ideal: 400, max: 1000)
        /**/
    }
}
