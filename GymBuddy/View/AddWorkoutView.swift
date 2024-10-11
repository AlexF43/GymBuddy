//
//  AddWorkoutView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

struct AddWorkoutView: View {
    @StateObject private var viewModel = AddWorkoutViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Workout Description", text: $viewModel.description)
                
                Section(header: Text("Exercises")) {
                    ForEach($viewModel.exercises) { $exercise in
                        AddExerciseRowView(exercise: $exercise)
                    }
                    Button("Add Exercise") {
                        viewModel.addingExercise = true
                    }
                }
                
                Button("Save Workout") {
                    viewModel.saveWorkout { success, error in
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            if let error = error {
                                print("Error saving workout: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.addingExercise) {
                ExerciseSelectionSheet(viewModel: viewModel, isPresented: $viewModel.addingExercise)
            }
            .navigationTitle("Add Workout")
        }
    }
}

#Preview {
    AddWorkoutView()
}
