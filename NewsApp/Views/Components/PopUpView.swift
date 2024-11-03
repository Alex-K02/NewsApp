//
//  PopUpView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 25.09.24.
//

import SwiftUI

struct PopUpView: View {
    let text: String
    let backgroundColor: Color
    
    var body: some View {
        VStack {
            Text(text)
                .font(.headline)
                .padding()
                .background(backgroundColor)
                .cornerRadius(10)
                .foregroundColor(.white)
                .shadow(radius: 10)
            
            Spacer() // Spacer to push the message to the top
        }
        .padding(.top)
        .frame(maxWidth: .infinity)
        .transition(.move(edge: .top))
    }
}

#Preview {
    PopUpView(text: "Data saved successfully", backgroundColor: Color.green)
}
