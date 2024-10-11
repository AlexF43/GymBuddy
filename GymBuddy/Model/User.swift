//
//  UserModel.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import Foundation
import FirebaseFirestore

struct User: Codable {
    @DocumentID var id: String?
    var email: String
    var username: String?
    var following: [String]
    var followerCount: Int

    init(id: String, email: String, username: String? = nil, following: [String] = [], followerCount: Int = 0) {
        self.id = id
        self.email = email
        self.username = username
        self.following = following
        self.followerCount = followerCount
    }
}
