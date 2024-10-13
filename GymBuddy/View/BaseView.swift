//
//  BaseView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

/// base view that a logged in user is shown, responsible for setting blank usernames and controlling the tab bar at the bottom of the screen
struct BaseView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State var tabSelection: Int = 1
    @State private var showingUsernameEntry = false
    
    var body: some View {
        ZStack {
            TabView(selection: $tabSelection) {
                ProfileView(userId: userViewModel.currentUser?.id ?? "")
                    .tabItem {
                        Label("My Profile", systemImage: "person.fill")
                    }
                    .tag(0)
                
                HomeView()
                    .environmentObject(userViewModel)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(1)
                
                AddWorkoutView()
                    .tabItem {
                        Label("Add Workout", systemImage: "figure.walk")
                    }
                    .tag(2)
            }
            .tint(.blue)
            
            if showingUsernameEntry {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                UsernameEntryView(isPresented: $showingUsernameEntry)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.default, value: showingUsernameEntry)
        .onAppear {
            checkUsername()
        }
        .onChange(of: userViewModel.currentUser?.username) { _ in
            checkUsername()
        }
    }
        
    func checkUsername() {
        showingUsernameEntry = userViewModel.currentUser?.username == nil ||
                               userViewModel.currentUser?.username == "" ||
                               userViewModel.currentUser?.username == "Username"
    }
}


