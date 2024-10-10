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
        VStack(alignment: .leading) {
            
            Text("Workout on : \(formattedDate(workout.date))")
                .font(.subheadline)
            
            if let description = workout.description {
                Text(description)
                    .font(.subheadline)
            }

            Text("Exercises: \(workout.exercises.count)")
                .font(.subheadline)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
