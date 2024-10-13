//
//  ExerciseModel.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import Foundation

struct Exercise: Decodable, Identifiable {
    let id: String
    var name: String
    var imageURL: String
    var type: ExerciseType
    var sets: [ExerciseSet]
    
    enum CodingKeys: String, CodingKey {
        case name, imageURL, type, sets
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID().uuidString
        name = try container.decode(String.self, forKey: .name)
        imageURL = try container.decode(String.self, forKey: .imageURL)
        let typeString = try container.decode(String.self, forKey: .type)
        type = ExerciseType(rawValue: typeString) ?? .strength
        sets = try container.decode([ExerciseSet].self, forKey: .sets)
    }
    
    init(name: String, imageURL: String, type: ExerciseType, sets: [ExerciseSet]) {
        self.id = UUID().uuidString
        self.name = name
        self.imageURL = imageURL
        self.type = type
        self.sets = sets
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
                sets.append(ExerciseSet(data: .strength(reps: 10, weight: 0.0)))
            case .cardio:
                sets.append(ExerciseSet(data: .cardio(distance: 0.0, time: 10)))
            }
        }
    }
}
