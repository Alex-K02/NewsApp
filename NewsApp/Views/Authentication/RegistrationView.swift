//
//  SignUpView].swift
//  NewsApp
//
//  Created by Alex Kondratiev on 06.09.24.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var articleListViewModel: ArticlesListViewModel
    @EnvironmentObject var coreDataService: CoreDataService
    
    @State private var nameInput: String = ""
    @State private var emailInput: String = ""
    @State private var dateOfBirthInput: Date = Date()
    @State private var passwordInput: String = ""
    @State private var confirmPasswordInput: String = ""
    
    //MARK: - PopUp Variables
    @State private var showPopUp: Bool = false
    @State private var popUpText: String = ""
    @State private var popUpColor: Color = .red
    
    @State private var isRegistered: Bool = false
    @State private var showSuccessMessage = false

    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
                        LogoNameView()
                        
                        Text("Get daily insights and updates")
                            .font(.headline)
                            .foregroundStyle(.black)
                        
                        BackgroundImage(imageName: "sign-up-background", imageHeight: 150)
                        
                        VStack(alignment: .leading) {
                            FormFieldView(text: $nameInput, title: "Full Name", placeholder: "Enter your name")
                                .disableAutocorrection(true)
                            FormFieldView(text: $emailInput, title: "Email", placeholder: "name@example.com")
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .padding(.top)
                            
                            DateFieldView(title: "Date of Birth", date: $dateOfBirthInput)
                                .padding(.top)
                            
                            FormFieldView(text: $passwordInput, title: "Password", placeholder: "Enter your password", isSecure: true)
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

                            
                            AuthButtonView(title: "Register", action: {
                                Task {
                                    let result = await coreDataService.handleUserRegistration(email: emailInput, name: nameInput, dateOfBirth: dateOfBirthInput, password: passwordInput)
                                    
                                    switch result {
                                    case .success(_):
                                        isRegistered = true
                                    case .failure(let message):
                                        popUpText = message
                                    }
                                    
                                    // Show the pop-up
                                    withAnimation {
                                        showPopUp = true
                                    }
                                    
                                    // Hide the pop-up after 2 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            showPopUp = false
                                        }
                                    }
                                }
                            })
                            .disabled(!formIsValid)
                            .opacity(formIsValid ? 1.0 : 0.5)
                            .navigationDestination(isPresented: $isRegistered) {
                                LoginView()
                                    .navigationBarBackButtonHidden(true)
                            }
                            .alert(isPresented: $isRegistered) {
                                Alert(
                                    title: Text("Success"),
                                    message: Text("Account was successfully created."),
                                    dismissButton: .default(Text("OK")) {
                                        showSuccessMessage = true
                                    }
                                )
                            }
                            
                            Button {
                                dismiss()
                            } label: {
                                VStack {
                                    Text("Already have an account?")
                                    Text("Sign In")
                                        .foregroundStyle(.blue)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            }
                            
                        }
                        .padding()
                    }
                }
                if showPopUp {
                    ZStack {
                        PopUpView(text: popUpText, backgroundColor: popUpColor)
                            .frame(maxWidth: .infinity)
                            .transition(.move(edge: .top))
                            .zIndex(1)
                    }
                }
            }
        }
    }
}

//MARK: - AuthenticationFormProtocol

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !emailInput.isEmpty
        && emailInput.contains("@")
        && !passwordInput.isEmpty
        && passwordInput.count >= 8
        && confirmPasswordInput == passwordInput
        && !nameInput.isEmpty
    }
}


#Preview {
    RegistrationView()
}
