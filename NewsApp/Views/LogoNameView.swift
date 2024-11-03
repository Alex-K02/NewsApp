//
//  SwiftUIView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 06.09.24.
//

import SwiftUI

struct LogoNameView: View {
    var body: some View {
        ZStack {
            Text("About IT")
                .font(.title)
        }
        .padding()
        Spacer()
    }
}

#Preview {
    LogoNameView()
}
