//
//  WorkoutModel.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import Foundation
import FirebaseFirestore

struct Workout: Codable, Identifiable {
    @DocumentID var id: String?
    var date: Date
    var description: String?
    var exercises: [Exercise]
}
