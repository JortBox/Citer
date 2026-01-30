//
//  citationManagerApp.swift
//  citationManager
//
//  Created by Jort Boxelaar on 16/01/2024.
//

import SwiftUI
import SwiftData

@main
struct CiterApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Paper.self,
            Collection.self,
            Tag.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        
        Window("Add Manual Entry", id: "Form") {
            FormView()
                .frame(width: 400, height: 400)
        }
        .windowResizability(.contentSize)
        .modelContainer(sharedModelContainer)
        
        WindowGroup("Info", id: "Info", for: Paper.ID.self) { $paperId in
            if (paperId != nil) {
                List { InfoView(paperId: paperId!) }
                    .frame(width: 400, height: 600)
            } else { ErrorPaperView() }
        }
        .windowResizability(.contentSize)
        .modelContainer(sharedModelContainer)
        
        WindowGroup("Reference", id: "Reference", for: Paper.ID.self) { $paperId in
            if (paperId != nil) {
                ExtraDetailView(paperId: paperId!)
                    .frame(minWidth: 400, idealWidth: 400 ,minHeight: 800, idealHeight: 800)
            } else { ErrorPaperView() }
        }
        .modelContainer(sharedModelContainer)
        
        WindowGroup("Table", id: "Table", for: Catalog.ID.self) { $catalogId in
            if (catalogId != nil) {
                TableWindowView(catalogId: catalogId!)
                    .frame(minWidth: 400, idealWidth: 400 ,minHeight: 800, idealHeight: 800)
            } else { ErrorPaperView() }
        }
        .modelContainer(sharedModelContainer)
        

        
        Settings {
            SettingsView()
                .frame(width: 400, height: 250)
        }
    }
}
