//
//  UserViewModel.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn = false
    @Published var isLoading = true
    @Published var workouts: [Workout] = []
    @Published var personalBests: [PersonalBest] = []
    private var db = Firestore.firestore()
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        setupAuthStateDidChangeListener()
    }

    deinit {
        removeAuthStateDidChangeListener()
    }

    private func setupAuthStateDidChangeListener() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            if let firebaseUser = firebaseUser {
                self?.fetchUser(with: firebaseUser.uid)
            } else {
                DispatchQueue.main.async {
                    self?.currentUser = nil
                    self?.isLoggedIn = false
                    self?.isLoading = false
                }
            }
        }
    }

    private func removeAuthStateDidChangeListener() {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            } else {
                if let uid = authResult?.user.uid {
                    self?.fetchUser(with: uid)
                }
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            }
        }
    }

    func fetchUser(with uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user: \(error)")
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                return
            }

            guard let document = document, document.exists else {
                print("No user document found")
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                return
            }

            do {
                let user = try document.data(as: User.self)
                DispatchQueue.main.async {
                    self?.currentUser = user
                    self?.isLoggedIn = true
                    self?.isLoading = false
                    self?.fetchWorkouts()
                }
            } catch {
                print("Error decoding user: \(error)")
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isLoggedIn = false
            }
        } catch {
            print("Error signing out: \(error)")
        }
    }

    func createUser(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }

            guard let uid = authResult?.user.uid else {
                DispatchQueue.main.async {
                    completion(false, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"]))
                }
                return
            }

            let newUser = User(id: uid, email: email, username: nil, following: [], followerCount: 0)
            do {
                try self?.db.collection("users").document(uid).setData(from: newUser)
                DispatchQueue.main.async {
                    self?.currentUser = newUser
                    self?.isLoggedIn = true
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }

    func updateUsername(username: String, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUser?.id else {
            completion(false)
            return
        }
        
        db.collection("users").document(userId).updateData(["username": username]) { [weak self] error in
            if let error = error {
                print("Error updating username: \(error)")
                completion(false)
            } else {
                DispatchQueue.main.async {
                    self?.currentUser?.username = username
                    completion(true)
                }
            }
        }
    }

    func followUser(userId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let currentUserId = currentUser?.id else {
            completion(false, NSError(domain: "GymBuddy", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user not found"]))
            return
        }
        
        let userRef = db.collection("users").document(currentUserId)
        
        userRef.updateData([
            "following": FieldValue.arrayUnion([userId])
        ]) { [weak self] error in
            if let error = error {
                print("Error following user: \(error)")
                completion(false, error)
            } else {
                DispatchQueue.main.async {
                    self?.currentUser?.following.append(userId)
                    self?.updateFollowerCount(for: userId, increment: true)
                    completion(true, nil)
                }
            }
        }
    }

    func unfollowUser(userId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let currentUserId = currentUser?.id else {
            completion(false, NSError(domain: "GymBuddy", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user not found"]))
            return
        }
        
        let userRef = db.collection("users").document(currentUserId)
        
        userRef.updateData([
            "following": FieldValue.arrayRemove([userId])
        ]) { [weak self] error in
            if let error = error {
                print("Error unfollowing user: \(error)")
                completion(false, error)
            } else {
                DispatchQueue.main.async {
                    self?.currentUser?.following.removeAll { $0 == userId }
                    self?.updateFollowerCount(for: userId, increment: false)
                    completion(true, nil)
                }
            }
        }
    }

    func updateFollowerCount(for userId: String, increment: Bool) {
        let userRef = db.collection("users").document(userId)
        
        userRef.updateData([
            "followerCount": FirebaseFirestore.FieldValue.increment(increment ? Int64(1) : Int64(-1))
        ]) { error in
            if let error = error {
                print("Error updating follower count: \(error)")
            }
        }
    }

    func fetchFollowing(completion: @escaping ([User]?, Error?) -> Void) {
        guard let currentUserId = currentUser?.id else {
            completion(nil, NSError(domain: "GymBuddy", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user not found"]))
            return
        }
        
        db.collection("users").whereField("id", in: currentUser?.following ?? []).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching following: \(error)")
                completion(nil, error)
                return
            }
            
            let followingUsers = querySnapshot?.documents.compactMap { document -> User? in
                try? document.data(as: User.self)
            } ?? []
            
            completion(followingUsers, nil)
        }
    }

    func fetchFollowers(completion: @escaping ([User]?, Error?) -> Void) {
        guard let currentUserId = currentUser?.id else {
            completion(nil, NSError(domain: "GymBuddy", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user not found"]))
            return
        }
        
        db.collection("users").whereField("following", arrayContains: currentUserId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching followers: \(error)")
                completion(nil, error)
                return
            }
            
            let followers = querySnapshot?.documents.compactMap { document -> User? in
                try? document.data(as: User.self)
            } ?? []
            
            completion(followers, nil)
        }
    }

    func searchUsers(by username: String, completion: @escaping ([User]?, Error?) -> Void) {
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion([], nil)
            return
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "GymBuddy", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"]))
            return
        }
        
        let lowercasedUsername = username.lowercased()
        let endUsername = "\u{f8ff}" + lowercasedUsername + "\u{f8ff}"
        
        let query = db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: lowercasedUsername)
            .whereField("username", isLessThan: endUsername)
            .limit(to: 20)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error searching users: \(error)")
                completion(nil, error)
                return
            }
            
            let users = querySnapshot?.documents.compactMap { document -> User? in
                do {
                    var user = try document.data(as: User.self)
                    user.id = document.documentID
                    if user.id != currentUserId {
                        return user
                    } else {
                        return nil
                    }
                } catch {
                    print("Error decoding user: \(error)")
                    return nil
                }
            } ?? []
            
            completion(users, nil)
        }
    }

    func fetchMostFollowedUsers(limit: Int = 10, completion: @escaping ([User]?, Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "GymBuddy", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"]))
            return
        }
        
        db.collection("users")
            .order(by: "followerCount", descending: true)
            .limit(to: limit + 1)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching most followed users: \(error)")
                    completion(nil, error)
                    return
                }
                
                var users = querySnapshot?.documents.compactMap { document -> User? in
                    do {
                        var user = try document.data(as: User.self)
                        user.id = document.documentID
                        // Exclude the current user
                        if user.id != currentUserId {
                            return user
                        } else {
                            return nil
                        }
                    } catch {
                        print("Error decoding user: \(error)")
                        return nil
                    }
                } ?? []
                
                if users.count > limit {
                    users = Array(users.prefix(limit))
                }
                
                completion(users, nil)
            }
    }

    func fetchWorkouts() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("workouts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error fetching workouts: \(error)")
                    return
                }
                
                let fetchedWorkouts = querySnapshot?.documents.compactMap { document -> Workout? in
                    do {
                        var workout = try document.data(as: Workout.self)
                        workout.id = document.documentID
                        return workout
                    } catch {
                        print("Error decoding workout: \(error)")
                        return nil
                    }
                } ?? []
                
                DispatchQueue.main.async {
                    self?.workouts = fetchedWorkouts
                }
            }
    }
    
    func getUserWorkouts(userId: String, completion: @escaping ([Workout]?, Error?) -> Void) {
        db.collection("workouts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching workouts: \(error)")
                    completion(nil, error)
                    return
                }
                
                let fetchedWorkouts = querySnapshot?.documents.compactMap { document -> Workout? in
                    do {
                        var workout = try document.data(as: Workout.self)
                        workout.id = document.documentID
                        return workout
                    } catch {
                        print("Error decoding workout: \(error)")
                        return nil
                    }
                } ?? []
                
                DispatchQueue.main.async {
                    completion(fetchedWorkouts, nil)
                }
            }
    }
    
    func checkAndUpdateUsername(username: String, completion: @escaping (Bool, String?) -> Void) {
        // Check if username already exists
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { [weak self] (querySnapshot, err) in
            if let err = err {
                print("Error checking username: \(err)")
                completion(false, "An error occurred. Please try again.")
                return
            }
            
            // If username already exists
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                completion(false, "Username already taken. Please choose another.")
                return
            }
            
            // If username is unique, update it
            guard let userId = self?.currentUser?.id else {
                completion(false, "User not found.")
                return
            }
            
            self?.db.collection("users").document(userId).updateData(["username": username]) { error in
                if let error = error {
                    print("Error updating username: \(error)")
                    completion(false, "Failed to update username. Please try again.")
                } else {
                    DispatchQueue.main.async {
                        self?.currentUser?.username = username
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    func getPersonalBests(for userId: String, completion: @escaping ([PersonalBest]?, Error?) -> Void) {
        db.collection("personalBests")
            .whereField("userId", isEqualTo: userId)
            .order(by: "dateAchieved", descending: true)
            .limit(to: 10)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }

                let personalBests = querySnapshot?.documents.compactMap { document -> PersonalBest? in
                    do {
                        return try document.data(as: PersonalBest.self)
                    } catch {
                        print("Error decoding personal best: \(error)")
                        return nil
                    }
                } ?? []
                DispatchQueue.main.async {
                    completion(personalBests, nil)
                }
            }
    }

    // Fetch personal bests for the current user
    func getCurrentUserPersonalBests(completion: @escaping ([PersonalBest]?, Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "UserViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"]))
            return
        }

        getPersonalBests(for: currentUserId, completion: completion)
    }

    // Fetch recent personal bests from users the current user is following
    func getRecentPersonalBestsFromFollowing(limit: Int = 20, completion: @escaping ([PersonalBest]?, Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "UserViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"]))
            return
        }

        db.collection("users").document(currentUserId).getDocument { [weak self] (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let following = document?.data()?["following"] as? [String] else {
                completion([], nil)
                return
            }

            self?.db.collection("personalBests")
                .whereField("userId", in: following)
                .order(by: "dateAchieved", descending: true)
                .limit(to: limit)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }

                    let personalBests = querySnapshot?.documents.compactMap { document -> PersonalBest? in
                        do {
                            return try document.data(as: PersonalBest.self)
                        } catch {
                            print("Error decoding personal best: \(error)")
                            return nil
                        }
                    } ?? []

                    completion(personalBests, nil)
                }
        }
    }

    // Fetch personal bests for a specific exercise
    func getPersonalBestsForExercise(_ exerciseName: String, completion: @escaping ([PersonalBest]?, Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "UserViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"]))
            return
        }

        db.collection("personalBests")
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("exerciseName", isEqualTo: exerciseName)
            .order(by: "dateAchieved", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }

                let personalBests = querySnapshot?.documents.compactMap { document -> PersonalBest? in
                    do {
                        return try document.data(as: PersonalBest.self)
                    } catch {
                        print("Error decoding personal best: \(error)")
                        return nil
                    }
                } ?? []

                completion(personalBests, nil)
            }
    }

    // Get the user's progress for a specific exercise over time
    func getExerciseProgressOverTime(_ exerciseName: String, completion: @escaping ([(Date, Double)]?, Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "UserViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"]))
            return
        }

        db.collection("workouts")
            .whereField("userId", isEqualTo: currentUserId)
            .order(by: "date", descending: false)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }

                let progress = querySnapshot?.documents.compactMap { document -> (Date, Double)? in
                    guard let date = (document.data()["date"] as? Timestamp)?.dateValue(),
                          let exercises = document.data()["exercises"] as? [[String: Any]] else {
                        return nil
                    }

                    if let exercise = exercises.first(where: { $0["name"] as? String == exerciseName }),
                       let sets = exercise["sets"] as? [[String: Any]],
                       let lastSet = sets.last {
                        if let weight = lastSet["weight"] as? Double {
                            return (date, weight)
                        } else if let distance = lastSet["distance"] as? Double,
                                  let time = lastSet["time"] as? TimeInterval {
                            let speed = distance / (time / 3600)
                            return (date, speed)
                        }
                    }

                    return nil
                } ?? []

                completion(progress, nil)
            }
    }

    // Update personal bests after a workout is saved
    func updatePersonalBestsAfterWorkout(_ workout: Workout) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        for exercise in workout.exercises {
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
                    let speed = distance / (time / 3600) // speed in km/h or mi/h
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
    
    func getPersonalBests(for userId: String, limit: Int = 10, completion: @escaping ([PersonalBest]?, Error?) -> Void) {
        db.collection("personalBests")
            .whereField("userId", isEqualTo: userId)
            .order(by: "dateAchieved", descending: true)
            .limit(to: limit)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }

                let personalBests = querySnapshot?.documents.compactMap { document -> PersonalBest? in
                    do {
                        return try document.data(as: PersonalBest.self)
                    } catch {
                        print("Error decoding personal best: \(error)")
                        return nil
                    }
                } ?? []

                completion(personalBests, nil)
            }
    }
    
func getRecentWorkoutsFromFollowing(limit: Int = 20, completion: @escaping ([Workout]?, Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "UserViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"]))
            return
        }

        db.collection("users").document(currentUserId).getDocument { [weak self] (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let following = document?.data()?["following"] as? [String] else {
                completion([], nil)
                return
            }

            self?.db.collection("workouts")
                .whereField("userId", in: following)
                .order(by: "date", descending: true)
                .limit(to: limit)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }

                    let workouts = querySnapshot?.documents.compactMap { document -> Workout? in
                        do {
                            return try document.data(as: Workout.self)
                        } catch {
                            print("Error decoding workout: \(error)")
                            return nil
                        }
                    } ?? []

                    completion(workouts, nil)
                }
        }
    }

    func getUserInfo(userId: String, completion: @escaping (User?, Error?) -> Void) {
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let document = document, document.exists else {
                completion(nil, NSError(domain: "UserViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }

            do {
                let user = try document.data(as: User.self)
                completion(user, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func isFollowing(userId: String) -> Bool {
        return currentUser?.following.contains(userId) ?? false
    }
    
}
