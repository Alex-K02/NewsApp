//
//  AuthButtonView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 22.09.24.
//

import SwiftUI

struct AuthButtonView: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .textCase(.uppercase)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.1137, green: 0.1373, blue: 0.1647))
                .cornerRadius(10)
        }
        .padding(.top, 38)
        .padding(.horizontal, 16)
    }
}

#Preview {
    AuthButtonView(title: "Register", action: {print("Registering")})
}
