//
//  InspectorView.swift
//  Citer
//
//  Created by Jort Boxelaar on 06/02/2024.
//

import SwiftUI


struct InspectorView: View {
    let paper: Paper
    @Binding var inspectorTab: tabSelection
    @State private var inspectorSearch: String = ""

    var body: some View {
        List {
            switch inspectorTab {
            case .bibliography:
                ReferenceListView(paper: paper, searchField: $inspectorSearch)
            case .info:
                InfoView(paperId: paper.id)
                    .frame(alignment: .topLeading)
            case .catalogs:
                CatalogsView(paper: paper)
            }
        }
        .inspectorColumnWidth(min: 300, ideal: 400, max: 1000)
        .scrollContentBackground(.hidden)
        .safeAreaBar(edge: .top, spacing: 0) {
            switch inspectorTab {
            case .bibliography:
                VStack(spacing: 0) {
                    Picker("", selection: $inspectorTab) {
                        Text("Bibliography").tag(tabSelection.bibliography)
                        Text("Info").tag(tabSelection.info)
                        Text("Catalogs").tag(tabSelection.catalogs)
                    }
                    .pickerStyle(.palette)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .frame(alignment: .leading)
                    //.background(.ultraThinMaterial)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search Bibliography By Author", text: $inspectorSearch)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 7)
                        if !inspectorSearch.isEmpty {
                            Button(action: {inspectorSearch = ""}, label: {Image(systemName: "multiply.circle.fill")})
                                .buttonStyle(.borderless)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    //.background(.ultraThinMaterial)
                    //.border(width: 1, edges: [.bottom], color: Color(.lightGray))
                }
                //.background(.ultraThinMaterial)
            case .info, .catalogs:
                Picker("", selection: $inspectorTab) {
                    Text("Bibliography").tag(tabSelection.bibliography)
                    Text("Info").tag(tabSelection.info)
                    Text("Catalogs").tag(tabSelection.catalogs)
                }
                .pickerStyle(.palette)
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .frame(alignment: .leading)
                //.background(.ultraThinMaterial)
                //.border(width: 1, edges: [.bottom], color: Color(.lightGray))
            }
        }
    }
}


enum tabSelection {
    case bibliography
    case info
    case catalogs
    
    var id: String {
        switch self {
        case .bibliography: return "bibliography"
        case .info: return "info"
        case .catalogs: return "catalogs"
        }
    }
    
    func title() -> String {
        switch self {
        case .bibliography: return "Bibliography"
        case .info: return "Info"
        case .catalogs: return "Catalogs"
        }
    }
}


struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}


extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
