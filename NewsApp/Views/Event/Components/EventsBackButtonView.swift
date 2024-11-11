//
//  EventsBackButtonView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 29.10.24.
//

import SwiftUI

struct EventsBackButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            VStack {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back")
                }
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(.black)
            .cornerRadius(10)
            .padding()
        })
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    @Previewable @Environment(\.dismiss) var dismiss
    EventsBackButtonView(action: {
        dismiss()
    })
}
