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
    var username: String?
    var following: [String]
    
    init(id: String? = nil, email: String, username: String? = nil, following: [String] = []) {
        self.id = id
        self.email = email
        self.username = username
        self.following = following
    }
}
