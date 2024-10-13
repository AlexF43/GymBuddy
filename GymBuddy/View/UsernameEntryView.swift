//
//  UsernameEntryView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

struct UsernameEntryView: View {
    @EnvironmentObject var viewModel: UserViewModel
    @Binding var isPresented: Bool
    @State private var username: String = ""
    @State private var errorMessage: String? = nil
    @State private var isChecking: Bool = false
    @FocusState private var focusedField: String?
    
    var body: some View {
        VStack {
            Text("Welcome to GymBuddy!")
                .font(.title)
                .padding()
            
            Text("Choose a unique username")
                .font(.headline)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .focused($focusedField, equals: "Username")
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: checkAndUpdateUsername) {
                if isChecking {
                    ProgressView()
                } else {
                    Text("Save")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(username.isEmpty || isChecking)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .padding()
    }
    
    private func checkAndUpdateUsername() {
        isChecking = true
        errorMessage = nil
        viewModel.checkAndUpdateUsername(username: username) { success, error in
            isChecking = false
            if success {
                focusedField = nil
                isPresented = false
            } else {
                errorMessage = error
            }
        }
    }
}



