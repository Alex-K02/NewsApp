//
//  ForgotPasswordView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 12.09.24.
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var coreDataService: CoreDataService
    @State private var emailInput: String = ""
    @State private var emailIsSent: Bool = false
    
    private let emailServiceController = EmailServiceController()
    
    var body: some View {
        NavigationStack {
            VStack {
                LogoNameView()
                
                BackgroundImage(imageName: "sign-in-background", imageHeight: 200)
                
                FormFieldView(text: $emailInput, title: "Email", placeholder: "Enter your email")
                    .padding()
                
                AuthButtonView(title: "Send Reset Link", action:  {
                    self.emailIsSent = emailServiceController.sendEmail(address: emailInput)
                })
                .navigationDestination(isPresented: $emailIsSent) {
                    LoginPageView()
                }
                
                Spacer()
                
                VStack {
                    NavigationLink {
                        LoginPageView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.blue)
                        Text("Back to login")
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
