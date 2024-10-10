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
    private let db = Firestore.firestore()
    
    func addExercise() {
        exercises.append(Exercise())
    }
    
    func saveWorkout(completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, NSError(domain: "AddWorkoutViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let workoutData: [String: Any] = [
            "userId": userId,
            "description": description,
            "date": Timestamp(date: Date()),
            "exercises": exercises.map { exercise in
                return [
                    "name": exercise.name,
                    "sets": exercise.sets.map { set in
                        return [
                            "weight": set.weight,
                            "reps": set.reps
                        ]
                    }
                ]
            }
        ]
        
        db.collection("workouts").addDocument(data: workoutData) { error in
            if let error = error {
                print("Error saving workout: \(error)")
                completion(false, error)
            } else {
                print("Workout successfully saved!")
                completion(true, nil)
            }
        }
    }
}
