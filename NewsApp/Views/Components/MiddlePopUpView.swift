//
//  MiddlePopUpView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 02.10.24.
//

import SwiftUI

struct MiddlePopUpView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthTokenManagerService
    
    let text: String
    @Binding var isPopUpActive: Bool
    let content: any View
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(text)
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .foregroundStyle(.black)
            }
            AnyView(content)
        }
        .frame(width: 300, height: 200) // Define pop-up size
        .background(.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 1))
        .padding()
        .zIndex(1) // Ensure it's on top
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Centering the pop-up
    }
}

#Preview {
    @Previewable @State var isPresented: Bool = true
    let userPreference = UserPreference(context: PersistenceController.shared.container.viewContext)
    let article = Article(context: PersistenceController.shared.container.viewContext)
    let event = Event(context: PersistenceController.shared.container.viewContext)
    let domain = FavoriteDomain(domain: "", likedAt: Date())
    MiddlePopUpView(text: "Are you sure you want to delete this favorite?", isPopUpActive: $isPresented, content: MiddlePopUpFavoriteContentView(userPreference: userPreference, isPopUpActive: $isPresented, article: article, author: "", domain: domain, event: event))
}
