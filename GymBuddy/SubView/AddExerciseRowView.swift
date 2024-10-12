//
//  AddExerciseView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

struct AddExerciseRowView: View {
    @Binding var exercise: Exercise
    @FocusState.Binding var focusedField: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Group {
                    if (exercise.imageURL.isEmpty) {
                        PlaceholderImageView(text: String(exercise.name.prefix(1).uppercased()), size: 15)
                    } else {
                        AsyncImage(url: URL(string: exercise.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure(_), .empty:
                                PlaceholderImageView(text: String(exercise.name.prefix(1).uppercased()), size: 15)
                            @unknown default:
                                PlaceholderImageView(text: String(exercise.name.prefix(1).uppercased()), size: 15)
                            }
                        }
                    }
                }
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .shadow(radius: 1)
                
                Text(exercise.name)
                    .font(.headline)
            }

            Picker("Exercise Type", selection: $exercise.type) {
                Text("Strength").tag(ExerciseType.strength)
                Text("Cardio").tag(ExerciseType.cardio)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            SetsHeaderView(exerciseType: exercise.type)
            
            ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, _ in
                SetRowView(
                    set: $exercise.sets[index],
                    setNumber: index + 1,
                    focusedField: $focusedField
                )
            }
            
            Button(action: {
                exercise.addSet()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                    Text("Add Set")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding()
    }
}


