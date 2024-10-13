//
//  SampleExercise.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

import Foundation

/// sample exercise model, matches the csv and is for the searchable list of workouts
struct SampleExercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imgURL: String
    let targetMuscle: String
    let type: ExerciseType
}
