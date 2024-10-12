//
//  ProfileView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

struct ProfileView: View {
    let userId: String
    @EnvironmentObject var viewModel: UserViewModel
    @State private var selectedTab: Int = 0
    @State private var searchUsers = false
    @State private var personalBests: [PersonalBest] = []
    @State private var user: User?
    @State private var workouts: [Workout] = []
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    HStack(spacing: 30) {
                        PlaceholderImageView(text: String(user?.username?.prefix(1).uppercased() ?? "U"), size: 50)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            .shadow(radius: 1)
                        
                        HStack(spacing: 30) {
                            StatView(value: "\(workouts.count)", title: "Workouts")
                            StatView(value: "\(user?.following.count ?? 0)", title: "Following")
                            StatView(value: "\(user?.followerCount ?? 0)", title: "Followers")
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user?.username ?? "Username")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Action Buttons
                    if isCurrentUserProfile {
                        HStack(spacing: 8) {
                            ProfileButton(title: "Edit Profile") {
                                // edit username etc
                            }
                            
                            ProfileButton(title: "Follow People") {
                                searchUsers = true
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        ProfileButton(title: viewModel.isFollowing(userId: userId) ? "Unfollow" : "Follow") {
                            if viewModel.isFollowing(userId: userId) {
                                viewModel.unfollowUser(userId: userId) { _, _ in }
                            } else {
                                viewModel.followUser(userId: userId) { _, _ in }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PERSONAL BESTS")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        if personalBests.isEmpty {
                            Text("No personal bests yet")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(personalBests, id: \.uniqueId) { pb in
                                        PersonalBestCardView(personalBest: pb)
                                            .frame(width: 160)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    .frame(height: 160)
                    //                .frame(height: 160)
                    
                    // Workouts Section
                    VStack(spacing: 15) {
                        Text("WORKOUTS")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ForEach(workouts) { workout in
                            WorkoutRowView(workout: workout)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationBarItems(trailing: Group {
                if isCurrentUserProfile {
                    Button(action: {
                        viewModel.logout()
                    }) {
                        Text("Logout")
                    }
                }
            })
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchUserData()
            fetchPersonalBests()
            fetchWorkouts()
        }
        .sheet(isPresented: $searchUsers) {
            SearchUsersView(viewModel: viewModel, isPresented: $searchUsers)
        }
    }
    
    private var isCurrentUserProfile: Bool {
        return userId == viewModel.currentUser?.id
    }
    
    private func fetchUserData() {
        if isCurrentUserProfile {
            self.user = viewModel.currentUser
        } else {
            viewModel.fetchUser(with: userId)
        }
    }
    
    private func fetchPersonalBests() {
        viewModel.getPersonalBests(for: userId) { pbs, error in
            if let error = error {
                print("Error fetching personal bests: \(error)")
            } else if let pbs = pbs {
                self.personalBests = pbs
            }
        }
    }
    
    private func fetchWorkouts() {
        viewModel.getUserWorkouts(userId: userId) { fetchedWorkouts, error in
            if let error = error {
                print("Error fetching workouts: \(error)")
            } else if let fetchedWorkouts = fetchedWorkouts {
                self.workouts = fetchedWorkouts
            }
        }
    }
}

