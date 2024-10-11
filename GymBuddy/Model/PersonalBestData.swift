//
//  PersonalBestData.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

enum PersonalBestData: Codable, Equatable {
    case strength(weight: Int)
    case cardio(speed: Double)

    enum CodingKeys: String, CodingKey {
        case type, weight, speed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "strength":
            let weight = try container.decode(Int.self, forKey: .weight)
            self = .strength(weight: weight)
        case "cardio":
            let speed = try container.decode(Double.self, forKey: .speed)
            self = .cardio(speed: speed)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid personal best type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .strength(let weight):
            try container.encode("strength", forKey: .type)
            try container.encode(weight, forKey: .weight)
        case .cardio(let speed):
            try container.encode("cardio", forKey: .type)
            try container.encode(speed, forKey: .speed)
        }
    }
    
    var asDictionary: [String: Any] {
        switch self {
        case .strength(let weight):
            return ["type": "strength", "weight": weight]
        case .cardio(let speed):
            return ["type": "cardio", "speed": speed]
        }
    }
}
