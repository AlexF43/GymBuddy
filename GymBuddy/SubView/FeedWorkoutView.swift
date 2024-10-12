//
//  FeedWorkoutView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 12/10/2024.
//

import SwiftUI

struct FeedWorkoutView: View {
    let workout: Workout
    let user: User?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                PlaceholderImageView(text: String(user?.username?.prefix(1).uppercased() ?? "U"), size: 15)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .shadow(radius: 1)
                if let username = user?.username {
                    Text(username)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            Text("Finished a workout")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            WorkoutRowView(workout: workout)
        }
    }
}
