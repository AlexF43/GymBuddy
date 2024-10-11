//
//  PlaceholderImageView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

import SwiftUI

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


