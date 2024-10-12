//
//  LoginView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome Back to GymBuddy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                TextField("Password", text: $password)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                
                Button(action: performLogin) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
                    .foregroundColor(.blue)
                    .padding(.top)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func performLogin() {
        userViewModel.login(email: email, password: password) { success, error in
            if !success {
                alertMessage = error?.localizedDescription ?? "Unknown error occurred"
                showAlert = true
            }
        }
    }
}
