//
//  ProfileView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

struct ProfileView: View {
    var userProfile: Bool
    @EnvironmentObject var viewModel: UserViewModel
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 30) {
                        PlaceholderImageView(text: String(viewModel.currentUser?.username?.prefix(1).uppercased() ?? "U"), size: 50)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            .shadow(radius: 1)
                        
                        Spacer()
                        
                        HStack(spacing: 50) {
                            StatView(value: "\(viewModel.workouts.count)", title: "Workouts")
                            StatView(value: "\(viewModel.currentUser?.following.count ?? 0)", title: "Following")
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.currentUser?.username ?? "Username")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    if userProfile {
                        HStack(spacing: 8) {
                            ProfileButton(title: "Edit Profile") {
                                // edit username ect
                            }
                            
                            ProfileButton(title: "Follow People") {
                                //follwo people
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        ProfileButton(title: "Follow") {
                            //follow if on someone elses page g
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 15) {
                        Text("WORKOUTS")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.workouts) { workout in
                            WorkoutRowView(workout: workout)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Group {
                if userProfile {
                    Button(action: {
                        //settnig
                    }) {
                        Image(systemName: "gear")
                    }
                }
            })
        }
        .onAppear {
            viewModel.fetchWorkouts()
        }
    }
}

