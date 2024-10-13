//
//  PlaceholderImageView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

import SwiftUI

/// default view for displaying in place of an image, used for profiles and workouts
struct PlaceholderImageView: View {
    var text: String
    var size: Int
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8)
            Text(text)
                .font(.system(size: CGFloat(size), weight: .bold))
               .foregroundColor(.white)
        }
    }
}


