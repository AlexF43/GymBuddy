//
//  StatView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//
import SwiftUI

struct StatView: View {
    let value: String
    let title: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
