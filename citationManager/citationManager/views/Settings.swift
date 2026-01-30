//
//  SettingsView.swift
//  Citer
//
//  Created by Jort Boxelaar on 26/03/2024.
//

import SwiftUI

struct SettingsView: View {
    
    private enum Tabs: Hashable {
        case general, advanced
    }
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            TokenSettingsView()
                .tabItem {
                    Label("API Token", systemImage: "arrow.right.arrow.left")
                }
                .tag(Tabs.advanced)
        }
        .padding(20)
        .frame(width: 375, height: 300)
    }
}


struct TokenSettingsView: View {
    @Environment(\.openURL) var openURL
    @State private var tokenText: String = ""
    @State private var adsToken: String = UserDefaults.standard.string(forKey: "adsToken") ?? ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Add your personal SAO/ADS NASA token to be able to add papers to your Library. [more info](https://ui.adsabs.harvard.edu/user/settings/token)")
                .padding(.horizontal, 5)
            
            Text(adsToken.isEmpty ? "No Active Token Found" : "Current Token: \(adsToken)")
                .padding(5)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
            
            Form {
                TextField("Add Token", text: $tokenText)
                    .onSubmit() {
                        UserDefaults.standard.set(tokenText, forKey: "adsToken")
                        adsToken = tokenText
                        tokenText = ""
                    }
            }
        }
        //.padding(20)
        //.frame(width: 350, height: 130)
    }
}

struct GeneralSettingsView: View {
    @State private var showTags: Bool = UserDefaults.standard.bool(forKey: "showTags")
    @State private var maxRows: Int = UserDefaults.standard.integer(forKey: "maxRows")
    @State private var maxRowsText: String = String(UserDefaults.standard.integer(forKey: "maxRows"))
    
    var body: some View {
        VStack {
            Image("LogoCompact")
                .resizable()
                .frame(width: 225, height: 130)
                //.padding()
            Form {
                Toggle("Show tags in paper list", isOn: $showTags)
                    .toggleStyle(SwitchToggleStyle(tint: .accent))
                    .onChange(of: showTags, updateSetting)
                
                TextField("Max rows in Catalog Query (-1 for all entries)", text: $maxRowsText)
                    .onSubmit() {
                        maxRows = Int(maxRowsText) ?? 50
                        maxRowsText = String(maxRows)
                        updateSetting()
                    }
            }
        }
    }
    
    func updateSetting() -> Void {
        UserDefaults.standard.set(showTags, forKey: "showTags")
        UserDefaults.standard.set(maxRows, forKey: "maxRows")
    }
}
