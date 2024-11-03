//
//  EventGradientBackground.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 29.10.24.
//

import SwiftUI

struct EventGradientBackground: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }
}

#Preview {
    EventGradientBackground()
}
