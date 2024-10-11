//
//  SampleExercise.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

import Foundation

struct SampleExercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imgURL: String
    let targetMuscle: String
    let type: ExerciseType
}
