//
//  WorkoutModel.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import Foundation
import FirebaseFirestore

/// workout model, containg a list of exercises and other infomation, matches model in firebase
struct Workout: Decodable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var date: Date
    var description: String?
    var exercises: [Exercise]
    
    enum CodingKeys: String, CodingKey {
        case date, description, exercises, userId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let timestamp = try container.decode(Timestamp.self, forKey: .date)
        date = timestamp.dateValue()
        description = try container.decodeIfPresent(String.self, forKey: .description)
        exercises = try container.decode([Exercise].self, forKey: .exercises)
        userId = try container.decode(String.self, forKey: .userId)
    }
}


