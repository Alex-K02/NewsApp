//
//  FormFieldView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 22.09.24.
//

import SwiftUI

struct FormFieldView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecure: Bool = false
    @FocusState var focused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.secondary))
                    .focused($focused)
            } else {
                TextField(placeholder, text: $text)
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.secondary))
                    .focused($focused)
            }
        }
    }
}

#Preview {
    @Previewable @State var text: String = "example@example.com"
    FormFieldView(text: $text, title: "Email", placeholder: "Enter your email")
}
