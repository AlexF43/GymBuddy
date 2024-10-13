//
//  WorkoutView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 12/10/2024.
//

import SwiftUI

struct WorkoutView: View {
    let workout: Workout
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            if let description = workout.description {
                                Text(description)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            Text("EXERCISES")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 15) {
                                ForEach(workout.exercises) { exercise in
                                    ExerciseRowView(exercise: exercise)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                        .frame(width: geometry.size.width * 0.95)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Workout on \(workout.date, style: .date)")
        }
    }
}
