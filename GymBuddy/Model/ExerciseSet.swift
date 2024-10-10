//
//  ExerciseSet.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import Foundation

struct ExerciseSet: Codable, Identifiable {
    var id = UUID()
    var weight: String = ""
    var reps: String = ""
}
