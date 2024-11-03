//
//  EditButtonView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 01.10.24.
//

import SwiftUI

struct EditProfileButtonView: View {
    @Binding var showProfileEdit: Bool
    
    var body: some View {
        Button(action: {
            showProfileEdit.toggle()
        }) {
            VStack(alignment: .center) {
                HStack {
                    Text("Edit Profile")
                    Image(systemName: "chevron.down")
                        .imageScale(.small)
                }
                .frame(width: UIScreen.main.bounds.width * 0.6)
                .font(.subheadline)
                .foregroundStyle(Color.gray)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            }
        }
    }
}

#Preview {
    @Previewable @State var showProfileEdit: Bool = .init(false)
    EditProfileButtonView(showProfileEdit: $showProfileEdit)
}
