//
//  MiddlePopUpPasswordChangeContentView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 11.10.24.
//

import SwiftUI

struct MiddlePopUpPasswordChangeContentView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isPopUpActive: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.8)) {
                    isPopUpActive = false
                }
                dismiss()
            }) {
                Text("Ok")
                    .font(.footnote)
                    .textCase(.uppercase)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .frame(maxWidth: 150)
                    .background(Color(red: 0.1137, green: 0.1373, blue: 0.1647))
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    @Previewable @State var isPresented: Bool = true
    MiddlePopUpPasswordChangeContentView(isPopUpActive: $isPresented)
}
