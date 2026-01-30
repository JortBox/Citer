//
//  DetailView.swift
//  citationManager
//
//  Created by Jort Boxelaar on 17/01/2024.
//

import SwiftUI
import SwiftData
import OrderedCollections


struct TableWindowView: View {
    @StateObject var navigationManager = NavigationStateManager()
    
    let catalogId: UUID
    var catalog: Catalog? = nil
    @Query var tables: [Catalog]
    
    @State var table = VizierTable()
    @State var tableLoaded: Bool = false
    @State var showLoading: Bool = false
    
    var body: some View {
        var catalog: Catalog? {
            for item in tables {
                if item.id == catalogId {
                    return item
                }
            }
            return nil
        }
        
        if catalog != nil {
            VStack {
                Button {
                    if tableLoaded {
                        table = VizierTable()
                        catalog!.table = nil
                    } else {
                        //Task.detached {
                        //    showLoading.toggle()
                        //    catalog!.table = await VizierQuery(catalog: catalog!)
                        //    let (rows,cols) = makeIdentifiable(catalog!)
                        //    await table.columns = cols
                        //    await table.rows = rows
                        //    showLoading.toggle()
                        //}
                    }
                    tableLoaded.toggle()
                    
                } label: {
                    Label(tableLoaded ? "Unload Table" : "Fetch Table",
                          systemImage: tableLoaded ? "square.and.arrow.up" : "square.and.arrow.down")
                }
                .padding()
                .buttonStyle(.accessoryBar)
                
                if showLoading {
                    ProgressView()
                }
                
                TableView(table: $table, tableLoaded: $tableLoaded)
            }
            .navigationTitle("Table: \(catalog?.name ?? "")")
            
        } else {
            Text("Not supported")
        }
    }
}

@Observable
class VizierTable {
    var columns: [VizierTableColumns] = []
    var rows: [VizierTableRow] = []
    //var rows: some RandomAccessCollection<VizierTableRow> { [] }
}

struct VizierTableColumns: Identifiable {
    let id = UUID()
    let colname: String
    let fields: OrderedDictionary<String, Any>
}

struct VizierTableRow: Identifiable, Hashable {
    let id = UUID()
    let cols: [String]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

func makeIdentifiable(_ catalog: Catalog) -> ([VizierTableRow], [VizierTableColumns]) {
    let decodedTable = DecodeVizierTable(data: catalog.table!, catalog: catalog)
    var rows: [VizierTableRow] = []
    var cols: [VizierTableColumns] = []
    
    for col in decodedTable.keys {
        if col == "data" {
            for row in decodedTable["data"] as! [[String]] {
                rows.append(VizierTableRow(cols: row))
            }
        } else {
            cols.append(VizierTableColumns(colname: col, fields: decodedTable[col] as! OrderedDictionary<String, Any>))
        }
    }
    return (rows, cols)
}

