//
//  SignInView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 05.09.24.
//

import SwiftUI

struct LoginPageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var coreDataViewModel: CoreDataViewModel
    @EnvironmentObject private var authViewModel: AuthTokenManagerService
    @EnvironmentObject private var articleListViewModel: ArticlesListViewModel
    @EnvironmentObject private var eventsListViewModel: EventsListViewModel
    
    @State private var userIsLogged: Bool = false
    @State private var rememberMe: Bool = false
    
    //MARK: - PopUp Variables
    @State private var showPopUp: Bool = false
    @State private var popUpText: String = ""
    @State private var popUpColor: Color = .red
    
    //MARK: - User Input Variables
    @State private var emailInput: String = ""
    @State private var passwordInput: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
                        LogoNameView()

                        Text("Stay updated with the latest news!")
                            .font(.headline)
                            .foregroundStyle(.black)

                        BackgroundImage(imageName: "sign-in-background")

                        VStack(alignment: .leading) {
                            FormFieldView(text: $emailInput, title: "Email:", placeholder: "name@example.com")
                            
                            FormFieldView(text: $passwordInput, title: "Password:", placeholder: "Enter Your Password", isSecure: true)
                                .padding(.top)
                            
                            HStack(alignment: .center) {
                                RememberMeToggle(isOn: $rememberMe)
                                ForgotPasswordTextView()
                            }
                            .padding(.top)

                            AuthButtonView(title: "Log In", action: {
                                Task {
                                    let result = await coreDataViewModel.signInCheck(email: emailInput, password: passwordInput, rememberMe: rememberMe)
                                    
                                    switch result {
                                        case .success(_):
                                            userIsLogged = true
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
                            .navigationDestination(isPresented: $userIsLogged) {
                                MainPageView()
                                    .navigationBarBackButtonHidden(true)
                            }
                            
                            RegisterNowView()
                        }
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
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

extension LoginPageView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !emailInput.isEmpty
        && emailInput.contains("@")
        && !passwordInput.isEmpty
        && passwordInput.count >= 8
    }
}



// MARK: - Reusable Views and Modifiers

struct BackgroundImage: View {
    let imageName: String
    let imageHeight: CGFloat?
    
    init(imageName: String, imageHeight: CGFloat = 200) {
        self.imageName = imageName
        self.imageHeight = imageHeight
    }
    
    var body: some View {
        Image(imageName)
            .resizable()
            .frame(width: 300, height: imageHeight ?? 200)
            .cornerRadius(8)
    }
}

struct RememberMeToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text("Remember me")
                .foregroundColor(.black)
        }
        .toggleStyle(CheckboxToggleStyle())
    }
}

struct ForgotPasswordTextView: View {
    var body: some View {
        Spacer()
        NavigationLink(destination: ForgotPasswordView()) {
            Text("Forgot Password?")
                .foregroundStyle(.link)
        }
    }
}

struct RegisterNowView: View {
    var body: some View {
        VStack {
            Text("Don't have an account?")
            NavigationLink {
                RegistrationView()
                    .navigationBarBackButtonHidden(true)
            } label: {
                Text("Sign Up")
                    .foregroundColor(.blue)
                    .underline()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(.black)
                configuration.label
                    .foregroundColor(.black)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    LoginPageView()
}
