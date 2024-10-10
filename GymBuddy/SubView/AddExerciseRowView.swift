//
//  AddExerciseView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

struct AddExerciseRowView: View {
    @Binding var exercise: Exercise
    var exerciseOptions = ["Strength", "Cadio"]
    var body: some View {
        VStack {
            TextField("Name", text: $exercise.name)
            
            Picker("Exercise Type", selection: $exercise.type) {
                Text("Strength").tag(ExerciseType.strength)
                Text("Cardio").tag(ExerciseType.cardio)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            SetsHeaderView(exerciseType: exercise.type)
                        
            ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, _ in
                SetRowView(set: $exercise.sets[index], setNumber: index + 1)
            }
            
            Button("Add Set") {
                exercise.addSet()
            }.buttonStyle(.borderless)
        }
        .navigationTitle("Add Exercise")
    }
}


