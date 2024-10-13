//
//  PersonalBestCardView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 12/10/2024.
//

import SwiftUI

/// card view for showing personal bests on profile
struct PersonalBestCardView: View {
    let personalBest: PersonalBest
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text(personalBest.exerciseName)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                Text(personalBestValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(height: 120)
            Spacer()
        }
        .frame(width: 160)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 2, y: 2)
    }
    
    private var personalBestValue: String {
        switch personalBest.data {
        case .strength(let weight):
            return "\(weight) kg"
        case .cardio(let speed):
            return String(format: "%.1f km/h", speed)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: personalBest.dateAchieved)
    }
}
