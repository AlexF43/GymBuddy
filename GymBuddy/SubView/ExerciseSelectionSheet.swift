//
//  ExerciseSelectionSheet.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//
import SwiftUI

struct ExerciseSelectionSheet: View {
    @ObservedObject var viewModel: AddWorkoutViewModel
    @Binding var isPresented: Bool
    @State private var searchText = ""
    @State private var selectedExercises: Set<SampleExercise> = []
    
    let allExercises: [SampleExercise] = readExercisesFromCSV()
    
    var filteredExercises: [SampleExercise] {
        if searchText.isEmpty {
            return allExercises
        } else {
            return allExercises.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredExercises, selection: $selectedExercises) { exercise in
                Button(action: {
                    viewModel.addExercise(exercise)
                    isPresented = false
                }) {
                    ExerciseSearchRowView(sampleExercise: exercise)
                }
            }
            .navigationTitle("Select Exercises")
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
}
