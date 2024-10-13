//
//  ContentView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import SwiftUI
import SwiftData

/// content view, shows different screen depedning on the auth state of the app
struct ContentView: View {
    @StateObject var userViewModel = UserViewModel()

    var body: some View {
        Group {
            if userViewModel.isLoading {
                LoadingScreen()
            } else if userViewModel.isLoggedIn {
                BaseView()
                    .environmentObject(userViewModel)
            } else {
                LoginView()
                    .environmentObject(userViewModel)
            }
            
        }
    }
}
