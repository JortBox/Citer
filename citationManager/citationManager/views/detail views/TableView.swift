//
//  TableHeaderView.swift
//  Citer
//
//  Created by Jort Boxelaar on 22/12/2024.
//

import SwiftUI
import SwiftData

struct TableView: View {
    @Binding var table: VizierTable
    @Binding var tableLoaded: Bool
    
    @State var order: [KeyPathComparator<VizierTableRow>] = [.init(\.cols[0], order: .forward)] // Sorting criteria
    
    var body: some View {
        if tableLoaded {
            if #available(macOS 14.4, *) {
                Table(table.rows, sortOrder: $order) {
                    TableColumnForEach(table.columns) { col in
                        TableColumn(col.colname) { row in
                            Text(row.cols[table.columns.firstIndex(where: {$0.colname == col.colname}) ?? 1])
                        }
                    }
                }
                .tableStyle(.bordered)
                //.onChange(of: order) { newOrder in
                //    //VizierTable.sort(using: newOrder)
                //}
                //.task {
                //    //VizierTable.sort(using: order)
                //}
            }
        } else {
            Text("Catalogue Not Loaded")
        }
    }
}

