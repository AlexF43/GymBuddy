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
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Login") {
                    userViewModel.login(email: email, password: password) { success, error in
                        if !success {
                            alertMessage = error?.localizedDescription ?? "Unknown error occurred"
                            showAlert = true
                        }
                    }
                }
                
                NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
                    .padding()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
