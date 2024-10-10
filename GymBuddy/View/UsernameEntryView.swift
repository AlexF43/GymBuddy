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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Choose a unique username")) {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Button(action: checkAndUpdateUsername) {
                    if isChecking {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(username.isEmpty || isChecking)
            }
            .navigationTitle("Welcome to GymBuddy!")
        }
    }
    
    private func checkAndUpdateUsername() {
        isChecking = true
        errorMessage = nil
        viewModel.checkAndUpdateUsername(username: username) { success, error in
            isChecking = false
            if success {
                isPresented = false
            } else {
                errorMessage = error
            }
        }
    }
}

