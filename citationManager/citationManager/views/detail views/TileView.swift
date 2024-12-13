//
//  TileView.swift
//  Citer
//
//  Created by Jort Boxelaar on 17/02/2024.
//

import SwiftUI
import SwiftData

struct TileView: View {
    @EnvironmentObject var navigationManager: NavigationStateManager
    @Environment(\.openWindow) var openWindow
    
    @State private var itemSize: CGFloat = 200
    @State private var selection: String = "None"
                                    
    let papers: [Paper]
    
    var body: some View {
        ScrollView() {
            LazyVGrid(columns: columns, spacing: 40) {
                ForEach(papers) { paper in
                    Button(action: {
                        selection = paper.bibcode
                        //navigationManager.selectedPaper = paper
                        openWindow(id: "Reference", value: paper.id)
                    }, label: {
                        GalleryItem(paper: paper, size: itemSize, selection: $selection)
                    })
                    .buttonStyle(TileButton())
                    
                }
            }
        }
        .padding([.horizontal, .top])
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ItemSizeSlider(size: $itemSize)
                .padding(.vertical, 5)
        }
        .onTapGesture {
            selection = "None"
            navigationManager.selectedPaper = nil
        }
    }
    
    

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: itemSize, maximum: itemSize), spacing: 40, alignment: .top)]
    }

    private struct GalleryItem: View {
        @EnvironmentObject var navigationManager: NavigationStateManager
        
        var paper: Paper
        var size: CGFloat
        @Binding var selection: String
        
        var body: some View {
            var isSelected: Bool { selection == paper.bibcode }
            ZStack(alignment: .top) {
                
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? .accent : .clear)
                
                VStack(alignment: .leading) {
                    GalleryImage(paper: paper, size: size)
                        .frame(alignment: .center)
                        .padding(10)
                   
                    Text(paper.title)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .font(.body)
                        .textSelection(.enabled)
                        .lineLimit(4)
                    
                    HStack {
                        let authors = paper.authors.sorted(by: {$0.timestamp < $1.timestamp})
                        var displayText: String {
                            if authors.count == 1 {
                                return authors.first?.name ?? "Not Availible"
                            } else if authors.count == 2 {
                                return authors.map({$0.name}).joined(separator: " & ")
                            } else {
                                return "\(authors.first?.name ?? "Not Availible") et al."
                            }
                        }
                        
                        Text(displayText)
                            .font(.subheadline)
                            .foregroundStyle(isSelected ? .white : .secondary)
                            .lineLimit(1)
                        
                        Spacer()
                        Text(paper.year)
                            .font(.subheadline)
                            .foregroundStyle(isSelected ? .white : .secondary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                //.onTapGesture(count: 2) {
                //    selection = paper.bibcode
                //    navigationManager.selectedPaper = paper
                //    openWindow(id: "Reference", value: paper.id)
                //}
            }
            .frame(width: size)
            .contextMenu {
                PaperContextMenu(paper: paper)
            }
        }

        var isSelected: Bool {
            selection == paper.bibcode
        }
    }

    private struct GalleryImage: View {
        var paper: Paper
        var size: CGFloat
        
        var body: some View {
            if let thumbnail = convertPDFToImage(pdfURL: paper.docLink!){
                let thumbnailRatio = thumbnail.size.height / thumbnail.size.width
                Image(nsImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    
                    //.background(background)
                    .overlay(alignment: .topLeading) {
                        if paper.favourite {
                            Image(systemName: "star.fill")
                                .background(.yellow)
                                .cornerRadius(3)
                                .foregroundStyle(.primary)
                                .padding()
                                .font(.system(size: 20))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8).size(width: size, height: thumbnailRatio * size))
                    .frame(width: size, height: thumbnailRatio*size, alignment: .top)
            }
            else {
                Image(systemName: "doc.questionmark.fill")
                    .symbolVariant(.fill)
                    .font(.system(size: 40))
                    .foregroundColor(Color.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 8).size(width: size, height: size))
                    .frame(width: size, height: size, alignment: .top)
            }
        }
    }

    private struct ItemSizeSlider: View {
        @Binding var size: CGFloat

        var body: some View {
            HStack {
                Spacer()
                Slider(value: $size, in: 100...500)
                    .controlSize(.small)
                    .frame(width: 100)
                    .padding(.trailing)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ShapeStyleExample: ShapeStyle {
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        if environment.colorScheme == .light {
            return Color.purple
        } else {
            return Color.yellow
        }
    }
}

struct TileButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            //.padding(.vertical, 3)
            .padding(.horizontal, 15)
            .background(configuration.isPressed ? .accent : .clear)
            .foregroundStyle(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
