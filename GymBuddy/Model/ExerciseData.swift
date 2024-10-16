//
//  ExerciseData.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import Foundation

/// different data for strength for cardio
enum ExerciseData: Codable {
    case strength(reps: Int, weight: Double)
    case cardio(distance: Double, time: TimeInterval)
}
