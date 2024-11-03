//
//  MiddlePopUpFavoriteView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 11.10.24.
//

import SwiftUI

struct MiddlePopUpFavoriteContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    let userPreference: UserPreference
    @Binding var isPopUpActive: Bool
    
    let article: Article?
    let author: String
    let domain: String
    let event: Event?
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.8)) {
                    isPopUpActive = false
                }
            }) {
                Text("Cancel")
                    .font(.footnote)
                    .textCase(.uppercase)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .frame(maxWidth: 150)
                    .background(Color(red: 0.1137, green: 0.1373, blue: 0.1647))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await coreDataService.removeUserPrefernces(userPreference: userPreference, article: article, domain: domain, author: author, event: event)
                    isPopUpActive = false
                }
            }) {
                Text("Delete")
                    .font(.footnote)
                    .textCase(.uppercase)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.1137, green: 0.1373, blue: 0.1647))
                    .padding(.vertical, 10)
                    .frame(maxWidth: 150)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.1137, green: 0.1373, blue: 0.1647), lineWidth: 4)
                    )
            }
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var isPresented: Bool = true
    let userPreference = UserPreference(context: PersistenceController.shared.container.viewContext)
    let article = Article(context: PersistenceController.shared.container.viewContext)
    let event = Event(context: PersistenceController.shared.container.viewContext)
    MiddlePopUpFavoriteContentView(userPreference: userPreference, isPopUpActive: $isPresented, article: article, author: "", domain: "", event: event)
}
