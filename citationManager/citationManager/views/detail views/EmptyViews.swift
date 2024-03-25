//
//  EmptyPaperView.swift
//  Citer
//
//  Created by Jort Boxelaar on 18/02/2024.
//

import SwiftUI

struct EmptyPaperView: View {
    var body: some View {
        
        Image(systemName: "doc.questionmark.fill")
            .foregroundStyle(.secondary)
            .font(.system(size: 40))
            .padding()
        Text("Select something")
    }
}


struct ErrorPaperView: View {
    var body: some View {
        
        Image(systemName: "exclamationmark.octagon.fill")
            .foregroundStyle(.red)
            .font(.system(size: 40))
            .padding()
        Text("Error occured while loading paper")
    }
}
