//
//  EmptyPaperView.swift
//  Citer
//
//  Created by Jort Boxelaar on 18/02/2024.
//

import SwiftUI

struct EmptyPaperView: View {
    var body: some View {
        Image("Logo")
            .resizable()
            .frame(width: 400, height: 410)
            .padding()
        Image("LogoText")
            .resizable()
            .frame(width: 450, height: 230)
            .padding()
        //Text("Select Something")
    }
}


struct ErrorPaperView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .font(.system(size: 40))
                .padding()
            Text("Error Occured While Loading Paper")
            Text("(PDF Not Found)")
        }
    }
}
