//
//  ChangePasswordView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 11.10.24.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var userIsLogged: Bool = false
    @State private var userId: String?
    @State private var showPopUp: Bool = false
    @State private var popupMessage: String?
    @State private var gotoLogin: Bool = false
    
    @State private var passwordInput: String = ""
    @State private var confirmPasswordInput: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading) {
                    VStack {
                        Text("Need to update your password?")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)

                        BackgroundImage(imageName: "sign-in-background")
                        
                        FormFieldView(text: $passwordInput, title: "New Password", placeholder: "Enter your new password", isSecure: true)
                            .textInputAutocapitalization(.never)
                            .padding(.top)
                        
                        ZStack(alignment: .trailing) {
                            FormFieldView(text: $confirmPasswordInput, title: "Confirm Password", placeholder: "Confirm your password", isSecure: true)
                                .textInputAutocapitalization(.never)
                            
                            if !passwordInput.isEmpty && !confirmPasswordInput.isEmpty {
                                Image(systemName: passwordInput == confirmPasswordInput ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundStyle(passwordInput == confirmPasswordInput ? Color(.systemGreen) : Color(.systemRed))
                                    .padding(.trailing, 5)
                                    .offset(y: 15)
                            }
                        }
                        .padding(.top, 15)
                        
                        AuthButtonView(title: "Reset Password", action: {
                            Task {
                                authViewModel.loadJWTFromKeychain()
                                
                                // Check if user is logged in
                                if let loadedUserId = authViewModel.loadIdValue(token: authViewModel.userJWTSessionToken), authViewModel.isUserLoggedIn() {
                                    self.userId = loadedUserId
                                    
                                    // Fetch data from Core Data
                                    let users = try await coreDataService.extractDataFromCoreData() as [User]
                                    
                                    // Find user by ID
                                    if let foundUser = users.first(where: { $0.id?.uuidString == self.userId }) {
                                        let user = foundUser
                                        await coreDataService.saveUserData(user: user, email: user.email ?? "", dateOfBirth: user.dateOfBirth ?? Date(), password: passwordInput)
                                        popupMessage = "Your password is now updated!"
                                        showPopUp.toggle()
                                    }
                                    else {
                                        print("No user was found")
                                        gotoLogin = true
                                    }
                                }
                                else {
                                    print("No user id loaded or user not logged in.")
                                    gotoLogin = true
                                }
                            }
                        })
                        .disabled(!formIsValid)
                        .opacity(formIsValid ? 1.0 : 0.5)
                        .navigationDestination(isPresented: $gotoLogin) {
                            LoginView()
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                if showPopUp {
                    MiddlePopUpView(
                        text: popupMessage ?? "Error",
                        isPopUpActive: $showPopUp,
                        content: MiddlePopUpPasswordChangeContentView(isPopUpActive: $showPopUp)
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

#Preview {
    ChangePasswordView()
}


extension ChangePasswordView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !passwordInput.isEmpty
        && passwordInput.count >= 8
    }
}
