//
//  AddWorkoutViewModel.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import Firebase

class AddWorkoutViewModel: ObservableObject {
    @Published var description: String = ""
    @Published var exercises: [Exercise] = []
    @Published var addingExercise = false
    @Published var isSaving = false
    @Published var showingSaveConfirmation = false
    private let db = Firestore.firestore()
    
    func addExercise(_ sampleExercise: SampleExercise) {
        var newExercise = Exercise(name: sampleExercise.name, imageURL: sampleExercise.imgURL, type: sampleExercise.type, sets: [])
        newExercise.addSet()
        exercises.append(newExercise)
    }
    
    func saveWorkout(completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, NSError(domain: "AddWorkoutViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        isSaving = true
        
        let workoutData: [String: Any] = [
            "userId": userId,
            "description": description,
            "date": Timestamp(date: Date()),
            "exercises": exercises.map { exercise in
                var exerciseData: [String: Any] = [
                    "name": exercise.name,
                    "imageURL": exercise.imageURL,
                    "type": exercise.type == .strength ? "strength" : "cardio"
                ]
                
                let setsData = exercise.sets.map { set in
                    switch set.data {
                    case .strength(let reps, let weight):
                        return [
                            "reps": reps,
                            "weight": weight
                        ]
                    case .cardio(let distance, let time):
                        return [
                            "distance": distance,
                            "time": time
                        ]
                    }
                }
                
                exerciseData["sets"] = setsData
                return exerciseData
            }
        ]
        
        db.collection("workouts").addDocument(data: workoutData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isSaving = false
                if let error = error {
                    print("Error saving workout: \(error)")
                    completion(false, error)
                } else {
                    print("Workout successfully saved!")
                    self?.showingSaveConfirmation = true
                    self?.resetWorkout()
                    completion(true, nil)
                }
            }
        }
    }
    
    func resetWorkout() {
        description = ""
        exercises = []
    }
}
