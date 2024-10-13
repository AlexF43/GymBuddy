//
//  AddWorkoutView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

/// base add workout view
struct AddWorkoutView: View {
    @StateObject private var viewModel = AddWorkoutViewModel()
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var focusedField: String?
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 20) {
                                TextField("Workout Notes", text: $viewModel.description, axis: .vertical)
                                    .lineLimit(3, reservesSpace: true)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    .focused($focusedField, equals: "workoutNotes")
                                
                                Text("EXERCISES")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 15) {
                                    ForEach($viewModel.exercises) { $exercise in
                                        AddExerciseRowView(exercise: $exercise, focusedField: $focusedField)
                                            .background(Color(.systemBackground))
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                }
                                
                                Button(action: {
                                    viewModel.addingExercise = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.blue)
                                        Text("Add Exercise")
                                            .fontWeight(.medium)
                                            .foregroundColor(.blue)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .padding(.bottom, 100)
                            }
                            .frame(width: geometry.size.width * 0.95)
                        }
                        
                        Spacer(minLength: 0)
                        
                        VStack {
                            Button(action: {
                                viewModel.saveWorkout { success, error in
                                    if !success, let error = error {
                                        print("Error saving workout: \(error.localizedDescription)")
                                    }
                                }
                            }) {
                                Text("Save Workout")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .disabled(viewModel.isSaving)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
                    }
                    
                    if viewModel.isSaving {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { _ in
                            focusedField = nil
                        }
                )
                .onTapGesture {
                    focusedField = nil
                }
            }
            .sheet(isPresented: $viewModel.addingExercise) {
                ExerciseSelectionSheet(viewModel: viewModel, isPresented: $viewModel.addingExercise)
            }
            .alert("Workout Saved", isPresented: $viewModel.showingSaveConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your workout has been successfully saved.")
            }
            .navigationTitle("Add Workout")
        }
    }
}
 

#Preview {
    AddWorkoutView()
}
