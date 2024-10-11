//
//  PersonalBest.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

import Foundation
import FirebaseFirestore

struct PersonalBest: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let exerciseName: String
    let dateAchieved: Date
    let type: ExerciseType
    let data: PersonalBestData

    var uniqueId: String {
        return id ?? "\(userId)_\(exerciseName)_\(dateAchieved.timeIntervalSince1970)"
    }

    enum CodingKeys: String, CodingKey {
        case id, userId, exerciseName, dateAchieved, type, data
    }

    init(id: String? = nil, userId: String, exerciseName: String, dateAchieved: Date, type: ExerciseType, data: PersonalBestData) {
        self.id = id
        self.userId = userId
        self.exerciseName = exerciseName
        self.dateAchieved = dateAchieved
        self.type = type
        self.data = data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        exerciseName = try container.decode(String.self, forKey: .exerciseName)
        dateAchieved = try container.decode(Timestamp.self, forKey: .dateAchieved).dateValue()
        type = try container.decode(ExerciseType.self, forKey: .type)
        
        let dataContainer = try container.nestedContainer(keyedBy: PersonalBestData.CodingKeys.self, forKey: .data)
        let dataType = try dataContainer.decode(String.self, forKey: .type)
        switch dataType {
        case "strength":
            let weight = try dataContainer.decode(Int.self, forKey: .weight)
            data = .strength(weight: weight)
        case "cardio":
            let speed = try dataContainer.decode(Double.self, forKey: .speed)
            data = .cardio(speed: speed)
        default:
            throw DecodingError.dataCorruptedError(forKey: .data, in: container, debugDescription: "Invalid personal best data type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(exerciseName, forKey: .exerciseName)
        try container.encode(Timestamp(date: dateAchieved), forKey: .dateAchieved)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
    }
}
