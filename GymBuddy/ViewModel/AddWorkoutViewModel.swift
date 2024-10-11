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
                    "type": exercise.type.rawValue
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
                    self?.checkAndUpdatePersonalBests(userId: userId)
                    self?.showingSaveConfirmation = true
                    self?.resetWorkout()
                    completion(true, nil)
                }
            }
        }
    }
    
    private func checkAndUpdatePersonalBests(userId: String) {
        for exercise in exercises {
            switch exercise.type {
            case .strength:
                if let maxWeightSet = exercise.sets.max(by: {
                    guard case let .strength(_, weight1) = $0.data,
                          case let .strength(_, weight2) = $1.data else { return false }
                    return weight1 < weight2
                }) {
                    guard case let .strength(_, maxWeight) = maxWeightSet.data else { continue }
                    updateStrengthPersonalBest(userId: userId, exerciseName: exercise.name, weight: maxWeight)
                }
            case .cardio:
                if let maxSpeedSet = exercise.sets.max(by: {
                    guard case let .cardio(distance1, time1) = $0.data,
                          case let .cardio(distance2, time2) = $1.data else { return false }
                    return (distance1 / time1) < (distance2 / time2)
                }) {
                    guard case let .cardio(distance, time) = maxSpeedSet.data else { continue }
                    let speed = distance / (time / 3600) 
                    updateCardioPersonalBest(userId: userId, exerciseName: exercise.name, speed: speed)
                }
            }
        }
    }
    
    private func updateStrengthPersonalBest(userId: String, exerciseName: String, weight: Double) {
        let personalBestRef = db.collection("personalBests").document("\(userId)_\(exerciseName)")
        
        personalBestRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                if let currentBest = document.data()?["weight"] as? Double, currentBest < weight {
                    self?.savePersonalBest(ref: personalBestRef, userId: userId, exerciseName: exerciseName, type: .strength, data: .strength(weight: Int(weight)))
                }
            } else {
                self?.savePersonalBest(ref: personalBestRef, userId: userId, exerciseName: exerciseName, type: .strength, data: .strength(weight: Int(weight)))
            }
        }
    }

    private func updateCardioPersonalBest(userId: String, exerciseName: String, speed: Double) {
        let personalBestRef = db.collection("personalBests").document("\(userId)_\(exerciseName)")
        
        personalBestRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                if let currentBest = document.data()?["speed"] as? Double, currentBest < speed {
                    self?.savePersonalBest(ref: personalBestRef, userId: userId, exerciseName: exerciseName, type: .cardio, data: .cardio(speed: speed))
                }
            } else {
                self?.savePersonalBest(ref: personalBestRef, userId: userId, exerciseName: exerciseName, type: .cardio, data: .cardio(speed: speed))
            }
        }
    }

    private func savePersonalBest(ref: DocumentReference, userId: String, exerciseName: String, type: ExerciseType, data: PersonalBestData) {
        let personalBestData: [String: Any] = [
            "userId": userId,
            "exerciseName": exerciseName,
            "dateAchieved": Timestamp(date: Date()),
            "type": type.rawValue,
            "data": data.asDictionary
        ]

        ref.setData(personalBestData) { error in
            if let error = error {
                print("Error saving personal best: \(error)")
            } else {
                print("Personal best saved successfully")
            }
        }
    }
    
    func resetWorkout() {
        description = ""
        exercises = []
    }
}
