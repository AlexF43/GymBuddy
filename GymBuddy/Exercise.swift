//
//  ExerciseModel.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import Foundation

struct Exercise: Codable {
    let name: String
    let sets: Int
    let reps: Int
    let weight: Double
}
