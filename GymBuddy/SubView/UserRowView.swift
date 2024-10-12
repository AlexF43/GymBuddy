//
//  UserRowView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

import SwiftUI

struct UserRowView: View {
    let user: User
    @ObservedObject var viewModel: UserViewModel
    
    private var isFollowing: Bool {
        viewModel.isFollowing(userId: user.id ?? "")
    }
    
    var body: some View {
        HStack {
            PlaceholderImageView(text: String(user.username?.prefix(1).uppercased() ?? ""), size: 25)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .shadow(radius: 1)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.username ?? "No username")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button(action: {
                if isFollowing {
                    viewModel.unfollowUser(userId: user.id ?? "") { _, _ in }
                } else {
                    viewModel.followUser(userId: user.id ?? "") { _, _ in }
                }
            }) {
                Text(isFollowing ? "Unfollow" : "Follow")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isFollowing ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }.buttonStyle(.borderless)
        }
        .padding(.vertical, 8)
    }
}
