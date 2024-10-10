//
//  ProfileView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: UserViewModel
        
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("User Info")) {
                    if let user = viewModel.currentUser {
                        Text("Username: \(user.username ?? "N/A")")
                        Text("Email: \(user.email)")
                    }
                }
                
                Section(header: Text("Workouts")) {
                    if viewModel.workouts.isEmpty {
                        Text("No workouts yet")
                    } else {
                        ForEach(viewModel.workouts) { workout in
                            WorkoutRowView(workout: workout)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                viewModel.fetchWorkouts()
            }
        }
    }
}

#Preview {
    ProfileView()
}
