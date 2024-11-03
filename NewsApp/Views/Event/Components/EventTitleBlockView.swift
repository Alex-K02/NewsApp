//
//  EventTitleBlockView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 27.10.24.
//

import SwiftUI

struct EventTitleBlockView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            
            Spacer()
            
            Image(systemName: "calendar")
                .imageScale(.large)
        }
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.349, green: 0.125, blue: 0.933))
        .cornerRadius(8)
    }
}

#Preview {
    EventTitleBlockView(title: "Events")
}
