//
//  CustomTabView.swift
//  Citer
//
//  Created by Jort Boxelaar on 09/12/2024.
//

import SwiftUI

public struct CustomTabView: View {
    private let titles: [String]
    private let icons: [String]
    private let tabViews: [AnyView]
    private let bordered: [Bool]

@State private var selection = 0
@State private var indexHovered = -1

    public init(content: [(title: String, icon: String, view: AnyView, bordered: Bool)]) {
    self.titles = content.map{ $0.title }
    self.icons = content.map{ $0.icon }
    self.tabViews = content.map{ $0.view }
    self.bordered = content.map{ $0.bordered }
}

public var tabBar: some View {
    HStack {
        Spacer()
        ForEach(0..<titles.count, id: \.self) { index in

            VStack {
                Image(systemName: self.icons[index])
                    .font(.title2)
                Text(self.titles[index])
            }
            .frame(height: 25)
            .padding(10)
            .background(Color.gray.opacity(((self.selection == index) || (self.indexHovered == index)) ? 0.1 : 0),
                        in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            .frame(height: 65)
            .padding(.horizontal, 0)
            .foregroundColor(self.selection == index ? Color(NSColor.controlAccentColor) : Color(NSColor.systemGray))
            .onHover(perform: { hovering in
                if hovering {
                    indexHovered = index
                } else {
                    indexHovered = -1
                }
            })
            .onTapGesture {
                self.selection = index
            }
        }
        Spacer()
    }
    .padding(0)
    .border(width: 1, edges: [.bottom], color: self.bordered[self.selection] ? Color(NSColor.lightGray) : Color.clear)

}

public var body: some View {
    VStack(spacing: 0) {
        tabBar

        tabViews[selection]
            .padding(0)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(0)
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
