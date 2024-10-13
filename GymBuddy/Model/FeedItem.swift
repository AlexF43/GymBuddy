//
//  FeedItem.swift
//  GymBuddy
//
//  Created by Alex Fogg on 12/10/2024.
//

import Foundation

/// general feeditem that allows workouts and personal bests to be combinded into a single list and displayed on the home screen
enum FeedItem: Identifiable {
    case workout(Workout, User?)
    case personalBest(PersonalBest, User?)

    var id: String {
        switch self {
        case .workout(let workout, _):
            return workout.id ?? UUID().uuidString
        case .personalBest(let pb, _):
            return pb.id ?? UUID().uuidString
        }
    }
}
