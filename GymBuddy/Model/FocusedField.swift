//
//  FocusedField.swift
//  GymBuddy
//
//  Created by Alex Fogg on 12/10/2024.
//

import Foundation

/// enum for handeling text field hiding with a potnentially infinite number of textfiends in the addworkout view
enum FocusedField: Hashable, Equatable {
    case weight(id: UUID)
    case reps(id: UUID)
    case distance(id: UUID)
    case time(id: UUID)
}
