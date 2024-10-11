//
//  WorkoutRowView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

struct WorkoutRowView: View {
    let workout: Workout
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 8) {
                Text("Workout on \(formattedDate(workout.date))")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let description = workout.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Image(systemName: workoutTypeIcon)
                        .foregroundColor(.blue)
                    
                    Text(workoutStats)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
    }
    
    private var workoutTypeIcon: String {
        isStrengthFocused ? "dumbbell.fill" : "figure.walk"
    }
    
    private var isStrengthFocused: Bool {
        let strengthExercises = workout.exercises.filter { $0.type == .strength }
        return strengthExercises.count > workout.exercises.count / 2
    }
    
    private var workoutStats: String {
        if isStrengthFocused {
            let totalSets = workout.exercises.reduce(0) { $0 + $1.sets.count }
            return "\(totalSets) sets across \(workout.exercises.count) exercises"
        } else {
            let totalDistance = workout.exercises.reduce(0.0) { total, exercise in
                total + exercise.sets.reduce(0.0) { setTotal, set in
                    if case .cardio(let distance, _) = set.data {
                        return setTotal + distance
                    }
                    return setTotal
                }
            }
            return String(format: "%.2f km across %d exercises", totalDistance, workout.exercises.count)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
