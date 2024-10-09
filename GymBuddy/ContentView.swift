//
//  ContentView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var userViewModel = UserViewModel()

    var body: some View {
        Group {
            if userViewModel.isLoggedIn {
                HomeView()
                    .environmentObject(userViewModel)
            } else {
                LoginView()
                    .environmentObject(userViewModel)
            }
            
        }
    }
}
