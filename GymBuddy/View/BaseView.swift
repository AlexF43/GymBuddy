//
//  BaseView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

struct BaseView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State var tabSelection: Int = 1
    @State private var showingUsernameEntry = false
    
    var body: some View {
        
        TabView(selection: $tabSelection) {
            ProfileView(userId: userViewModel.currentUser?.id ?? "")
                .tabItem{
                    Label("My Profile", systemImage: "person.fill")
                }
                .tag(0)
            
            HomeView()
                .environmentObject(userViewModel)
                .tabItem{
                    Label("Home", systemImage: "house")
                    
                }
                .tag(1)
            
            AddWorkoutView()
                .tabItem {
                    Label("Add Workout", systemImage: "figure.walk")
                }
                .tag(2)
            
        }.tint(.blue)
        
            .onAppear {
                checkUsername()
            }
            .onChange(of: userViewModel.currentUser?.username) { _ in
                checkUsername()
            }
            .sheet(isPresented: $showingUsernameEntry) {
                UsernameEntryView(isPresented: $showingUsernameEntry)
            }
    }
        
    func checkUsername() {
        if userViewModel.currentUser?.username == nil {
            showingUsernameEntry = true
        }
    }
}


