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
        .frame(width: 375, height: 150)
    }
}


struct TokenSettingsView: View {
    @Environment(\.openURL) var openURL
    @State private var tokenText: String = ""
    //@AppStorage("adsToken") private var adsToken: String = ""
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
        .frame(width: 350, height: 130)
    }
}

struct GeneralSettingsView: View {
    //@AppStorage("showPreview") private var showPreview = true
    //@AppStorage("fontSize") private var fontSize = 12.0


    var body: some View {
        Text("No General settings yet.")
        /*
        Form {
            Toggle("Show Previews", isOn: $showPreview)
            Slider(value: $fontSize, in: 9...96) {
                Text("Font Size (\(fontSize, specifier: "%.0f") pts)")
            }
        }
        .padding(20)
        .frame(width: 350, height: 100)
         */
    }
}
