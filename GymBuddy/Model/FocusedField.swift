//
//  FocusedField.swift
//  GymBuddy
//
//  Created by Alex Fogg on 12/10/2024.
//

import Foundation


enum FocusedField: Hashable, Equatable {
    case weight(id: UUID)
    case reps(id: UUID)
    case distance(id: UUID)
    case time(id: UUID)
}
