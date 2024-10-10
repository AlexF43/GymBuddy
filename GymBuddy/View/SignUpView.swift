//
//  SignUpView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 9/10/2024.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var viewModel: UserViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Sign Up") {
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
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .navigationTitle("Sign Up")
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Sign Up Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
