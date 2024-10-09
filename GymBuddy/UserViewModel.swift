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
                return
            }

            guard let document = document, document.exists else {
                print("No user document found")
                return
            }

            do {
                let user = try document.data(as: User.self)
                DispatchQueue.main.async {
                    self?.currentUser = user
                    self?.isLoggedIn = true
                }
            } catch {
                print("Error decoding user: \(error)")
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
}
