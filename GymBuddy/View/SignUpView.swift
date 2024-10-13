//
//  SignUpView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 9/10/2024.
//

import SwiftUI

/// screen allowing users to sign up to the application
struct SignUpView: View {
    @EnvironmentObject var viewModel: UserViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Start your Adventure")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            
            Button(action: performSignUp) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .navigationTitle("Sign Up")
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Sign Up Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func performSignUp() {
        if password == confirmPassword {
            viewModel.createUser(email: email, password: password) { success, error in
                if !success {
                    alertMessage = error?.localizedDescription ?? "Unknown error occurred"
                    showingAlert = true
                }
            }
        } else {
            alertMessage = "Passwords do not match"
            showingAlert = true
        }
    }
}
