//
//  PlaceholderImageView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

import SwiftUI

struct PlaceholderImageView: View {
    var text: String
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8)
            Text(text)
               .font(.system(size: 25, weight: .bold))
               .foregroundColor(.white)
        }
    }
}


