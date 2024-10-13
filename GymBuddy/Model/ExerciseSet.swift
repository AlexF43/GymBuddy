//
//  ExerciseSet.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import Foundation

/// set for an exercide, has different data depending on if it is for cardio or strength
struct ExerciseSet: Decodable, Identifiable {
    let id: String
    var data: ExerciseData
    
    init(data: ExerciseData) {
        self.id = UUID().uuidString
        self.data = data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID().uuidString
        
        if let type = try? container.decodeIfPresent(String.self, forKey: .type) {
            switch type {
            case "strength":
                let reps = try container.decode(Int.self, forKey: .reps)
                let weight = try container.decode(Double.self, forKey: .weight)
                data = .strength(reps: reps, weight: weight)
            case "cardio":
                let distance = try container.decode(Double.self, forKey: .distance)
                let time = try container.decode(TimeInterval.self, forKey: .time)
                data = .cardio(distance: distance, time: time)
            default:
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unknown exercise type"))
            }
        } else if let reps = try? container.decode(Int.self, forKey: .reps),
                  let weight = try? container.decode(Double.self, forKey: .weight) {
            data = .strength(reps: reps, weight: weight)
        } else if let distance = try? container.decode(Double.self, forKey: .distance),
                  let time = try? container.decode(TimeInterval.self, forKey: .time) {
            data = .cardio(distance: distance, time: time)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unable to decode ExerciseSet"))
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case reps, weight, distance, time, type
    }
}
