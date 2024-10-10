//
//  ExerciseModel.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import Foundation

class Exercise: Codable, Identifiable {
    var id = UUID()
    var name: String = ""
    var sets: [ExerciseSet] = [ExerciseSet()]

}
