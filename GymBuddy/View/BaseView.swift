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
    
    var body: some View {
        
        // tab view along the bottom of all view, allowing the user to switch between grades, home and assignments
        TabView(selection: $tabSelection) {
            ProfileView()
                .tabItem{
                    Label("My Profile", systemImage: "chart.bar")
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
    }
}


