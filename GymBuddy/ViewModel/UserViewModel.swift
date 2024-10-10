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
    @Published var workouts: [Workout] = []
    @Published var currentUser: User? {
        didSet {
            if currentUser != nil {
                fetchWorkouts()
            }
        }
    }
    @Published var isLoggedIn = false
    @Published var isLoading = true
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

            let newUser = User(id: uid, email: email)
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
    
    func fetchWorkouts() {
        guard let userId = currentUser?.id else { return }
        
        db.collection("workouts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error fetching workouts: \(error)")
                    return
                }
                
                let fetchedWorkouts = querySnapshot?.documents.compactMap { document -> Workout? in
                    try? document.data(as: Workout.self)
                } ?? []
                
                DispatchQueue.main.async {
                    self?.workouts = fetchedWorkouts
                }
            }
    }
}
