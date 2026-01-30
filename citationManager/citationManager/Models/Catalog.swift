//
//  Catalog.swift
//  Citer
//
//  Created by Jort Boxelaar on 16/12/2024.
//

import Foundation
import SwiftData
import OrderedCollections

@Model
final class Catalog {
    var id = UUID()
    var originalLink: String
    var link: String
    var catalogLink: String
    var url: URL?
    var catalogUrl: URL?
    var name: String
    var table: Data? = nil
    
    init(_ originalLink: String) {
        let name = originalLink.split(separator: "cat/").last!.uppercased()
        let link = originalLink.split(separator: "//").first! + "//vizier.cds.unistra.fr/viz-bin/VizieR?-source=" + name
        let cataloglink = originalLink.replacingOccurrences(of: "$VIZIER$", with: "vizier.cds.unistra.fr")
        let catalogUrl = URL(string: cataloglink)
        
        self.originalLink = originalLink
        self.url = URL(string: link)
        self.catalogUrl = catalogUrl
        self.catalogLink = cataloglink
        self.name = name
        self.link = link
        self.table = table
    }
}

// https://$VIZIER$/viz-bin/cat/VIII/65
// https://vizier.cds.unistra.fr/viz-bin/VizieR?-source=VII/255
