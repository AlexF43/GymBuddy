//
//  UserModel.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    let email: String
    var displayName: String?
    var workouts: [Workout]
    var following: [String]
    
    init(id: String? = nil, email: String, displayName: String? = nil, workouts: [Workout] = [], following: [String] = []) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.workouts = workouts
        self.following = following
    }
}
