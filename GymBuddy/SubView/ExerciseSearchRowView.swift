//
//  ExerciseSearchRowView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

import SwiftUI

struct ExerciseSearchRowView: View {
    var sampleExercise: SampleExercise
    var body: some View {
        HStack {
            Group {
                if (sampleExercise.imgURL == "") {
                    PlaceholderImageView(text: String(sampleExercise.name.prefix(1).uppercased()))
                } else {
                    AsyncImage(url: URL(string: sampleExercise.imgURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure(_), .empty:
                            PlaceholderImageView(text: String(sampleExercise.name.prefix(1).uppercased()))
                        @unknown default:
                            PlaceholderImageView(text: String(sampleExercise.name.prefix(1).uppercased()))
                        }
                    }
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            .shadow(radius: 1)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sampleExercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(sampleExercise.targetMuscle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ExerciseSearchRowView(sampleExercise: SampleExercise(name: "Squat", imgURL: "", targetMuscle: "Legs", type: .strength))
}
