//
//  ExerciseModel.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import Foundation

struct Exercise: Codable, Identifiable {
    let id = UUID()
    var name: String
    var type: ExerciseType
    var sets: [ExerciseSet]
    
    init() {
        self.name = ""
        self.type = .strength
        self.sets = []
    }
    
    mutating func addSet() {
        if let lastSet = sets.last {
            switch lastSet.data {
            case .strength(let reps, let weight):
                sets.append(ExerciseSet(data: .strength(reps: reps, weight: weight)))
            case .cardio(let distance, let time):
                sets.append(ExerciseSet(data: .cardio(distance: distance, time: time)))
            }
        } else {
            switch type {
            case .strength:
                sets.append(ExerciseSet(data: .strength(reps: 0, weight: 0.0)))
            case .cardio:
                sets.append(ExerciseSet(data: .cardio(distance: 0.0, time: 0)))
            }
        }
    }
}
