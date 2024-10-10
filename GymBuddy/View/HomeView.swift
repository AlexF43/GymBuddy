//
//  HomeView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 9/10/2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome, \(userViewModel.currentUser?.username ?? "User")!")
                Text(userViewModel.currentUser?.email ?? "No email")
                    .font(.title)
                    .padding()
                
                Button("Logout") {
                    userViewModel.logout()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("GymBuddy")
        }
    }
}
