import Foundation
import OrderedCollections

private let maxRows = UserDefaults.standard.integer(forKey: "maxRows")
private let scheme = "http"
private let host = "vizier.u-strasbg.fr"
private let path = "/viz-bin/votable/"

private let fieldsKey = "data"

func VizierQuery(catalog: Catalog, completion: @escaping (Data) -> Void) {
    let fieldsList = ["-source=\(catalog.name)", "-out=*", "-out.max=\(maxRows)", "-out.meta=huUD", "-out.form=mini", "-oc.form=d"]
    let session = URLSession.shared
    var url: URL {
        var components = URLComponents()
                
        components.scheme = scheme
        components.host = host
        components.path = path
        components.query = fieldsList.joined(separator: "&amp;")
        
        guard let finalURL = components.url else {
            fatalError("Unable to construct URL from VizieR Request")
        }
        return finalURL
    }
    
    let request = URLRequest(url: url)
    
    session.dataTask(with: request) { data, response, error in
        print("response VizieR: ", response?.description as Any)
        if let data = data {
            print(String(data: data, encoding: .utf8)!)
            //let table = DecodeVizierTable(data: data,  catalog: catalog)
            completion(data)
            return
        } else {
            //let emptyTable: OrderedDictionary<String, OrderedDictionary<String, Any>> = [:]
            completion(Data())
        }
    }.resume()
}

func VizierQuery(catalog: Catalog) async -> Data {
    await withCheckedContinuation { continuation in
        VizierQuery(catalog: catalog) { messages in
            continuation.resume(returning: messages)
        }
    }
}


func DecodeVizierTable(data: Data, catalog: Catalog) -> OrderedDictionary<String, Any> {
    var table: String = String(data: data, encoding: .utf8)!.slice(from: "<TABLE ", to: "</TABLE>")!
    var tableData: String = String(data: data, encoding: .utf8)!.slice(from: "<TABLEDATA>", to: "</TABLEDATA>")!
    var columnNames: OrderedDictionary<String, Any> = [:]
    
    var nextfield: Bool = true
    while nextfield {
        if let field = table.slice(from: "<FIELD ", to: ">") {
            let colKey = String(field.split(separator: " ").first!.split(separator: "=").last!)
            var colDict: OrderedDictionary<String, Any> = [:]
            
            for col in field.split(separator: " ").dropFirst() {
                let key = String(col.split(separator: "=").first!)
                let value = String(col.split(separator: "=").last!)
                colDict.updateValue(value, forKey: key)
            }
            columnNames.updateValue(colDict, forKey: colKey)
            table = table.dropNext(of: "<FIELD ")
        } else { nextfield = false}
    }
    
    var nextTr: Bool = true
    var tableRows: [[String]] = []
    while nextTr {
        if var tr = tableData.slice(from: "<TR>", to: "</TR>") {
            var tableColumns: [String] = []
            var nextTd: Bool = true
            while nextTd {
                if let td = tr.slice(from: "<TD>", to: "</TD>") {
                    tableColumns.append(td)
                    tr = "<TD>" + tr.dropNext(of: "<TD>")
                } else {
                    nextTd = false}
            }
            tableRows.append(tableColumns)
            tableData = tableData.dropNext(of: "<TR>")
        } else { nextTr = false}
    }
    
    columnNames.updateValue(tableRows, forKey: "data")
    
    return columnNames
}


extension String {
    func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return String(self[rangeFrom..<rangeTo])
    }
    
    func dropNext(of: String) -> String {
        return self.split(separator: of).dropFirst().joined(separator: of)
    }
    
}

func transpose<T>(_ input: [[T]], defaultValue: T) -> [[T]] {
    let columns = input.count
    let rows = input.reduce(0) { max($0, $1.count) }

    return (0 ..< rows).reduce(into: []) { result, row in
        result.append((0 ..< columns).reduce(into: []) { result, column in
            result.append(row < input[column].count ? input[column][row] : defaultValue)
        })
    }
}

