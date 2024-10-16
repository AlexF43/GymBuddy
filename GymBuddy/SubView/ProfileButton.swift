//
//  ProfileButton.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

import SwiftUI

/// general button for use on profile for addding friends
struct ProfileButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
