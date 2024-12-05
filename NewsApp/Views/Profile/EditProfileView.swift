//
//  EditProfileView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 19.09.24.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataViewModel: CoreDataViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var user: User?
    
    @State private var showPopUp: Bool = false
    @State private var isLoading = true
    
    @State private var email: String = ""
    @State private var dateOfBirth: Date = .init()
    
    @State private var password: String = "12345678"
    
    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Loading...")
                    .onAppear {
                        Task {
                            if let user = authViewModel.user {
                                self.user = user
                            } else {
                                try await authViewModel.loadUserData()
                                if let loadedUser = authViewModel.user {
                                    self.user = loadedUser
                                } else {
                                    // Handle the case where user data couldn't be loaded
                                    print("Failed to load user data.")
                                }
                            }
                            self.email = user?.email ?? "name@example.com"
                            self.isLoading = false
                        }
                    }
            } else {
                if let user = user {
                    ZStack {
                        ScrollView {
                            VStack(alignment: .leading) {
                                HStack {
                                    BackButtonView(action: {
                                        dismiss()
                                    })
                                }
                                ZStack {
                                    Text("Settings")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                }
                                
                                
                                VStack(alignment: .leading) {
                                    Text("Profile Settings")
                                        .bold()

                                    ZStack {
                                        VStack {
                                            CircleImage(text: user.intials, width: 100, height: 100, fontSize: .largeTitle)
                                                .frame(maxWidth: .infinity)
                                            Text(user.name!)
                                        }
                                    }
                                    .padding(.vertical)

                                    FormFieldView(text: $email, title: "Your Email:", placeholder: "name@example.com")
                                        .padding(.bottom)

                                    DateFieldView(title: "Birthday:", date: $dateOfBirth)
                                        .padding(.bottom)
                                    HStack(alignment: .center) {
                                        FormFieldView(text: $password, title: "Your Password:", placeholder: "Your password", isSecure: true)
                                            .padding(.bottom)
                                        NavigationLink(destination: ChangePasswordView()) {
                                            Image(systemName: "eye")
                                                .padding(.top)
                                        }
                                    }
                                    
                                }
                                .padding()
                                .background(.white)
                                .frame(width: UIScreen.main.bounds.width * 0.90)
                                .cornerRadius(10.0)
                                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 0)
                                .padding(.horizontal)
                                .padding(.bottom)
                                
                            }
                            SaveDataButton(action: {
                                Task {
                                    await coreDataViewModel.saveUserData(user: user, email: email, dateOfBirth: dateOfBirth, password: nil)
                                    showPopUp = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation(.easeInOut) {
                                        showPopUp = false
                                    }
                                }
                            })
                        }
                        if showPopUp {
                            ZStack {
                                PopUpView(text: "Your changes have been saved!", backgroundColor: Color.green)
                                    .frame(maxWidth: .infinity)
                                    .transition(.move(edge: .top))
                                    .zIndex(1)
                            }
                        }
                    }
                } else {
                    // If no user ID or user data, show LoginPageView
                    LoginPageView()
                }
            }
        }
    }
}

// MARK: - Reusable Views and Modifiers

struct CircleImage: View {
    var text: String
    var width: CGFloat = 72
    var height: CGFloat = 72
    var fontSize: Font = .title
    
    var body: some View {
        Text(text)
            .font(fontSize)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(width: width, height: height)
            .background(Color.gray)
            .clipShape(Circle())
    }
}

struct BackButtonView: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: "chevron.backward")
                Text("Back")
            }
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

struct SaveDataButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Save Changes")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 120, height: 15)
                .padding()
                .background(Color(.systemBlue))
                .cornerRadius(15)
        }
        .padding(.horizontal)
    }
}


// MARK: - Preview
#Preview {
    EditProfileView()
}
