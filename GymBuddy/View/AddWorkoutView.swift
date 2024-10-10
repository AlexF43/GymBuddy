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
        NavigationView {
            Form {
                TextField("Workout Description", text: $viewModel.description)
                
                Section(header: Text("Exercises")) {
                    ForEach(viewModel.exercises) { exercise in
                        Text(exercise.name)
                    }
                    Button("Add Exercise") {
                        viewModel.addExercise()
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
            .navigationTitle("Add Workout")
        }
    }
}

#Preview {
    AddWorkoutView()
}
