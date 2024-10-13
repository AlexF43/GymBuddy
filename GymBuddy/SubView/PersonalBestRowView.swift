//
//  PersonalBestRowView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 12/10/2024.
//

import SwiftUI

/// row view for showing personal bests on home screen
struct PersonalBestRowView: View {
    let personalBest: PersonalBest
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text(personalBest.exerciseName)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Text(personalBestValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
        return "Achieved on " + formatter.string(from: personalBest.dateAchieved)
    }
}
