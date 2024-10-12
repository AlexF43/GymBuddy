//
//  GymBuddyApp.swift
//  GymBuddy
//
//  Created by Alex Fogg on 8/10/2024.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct GymBuddyApp: App {
    init() {
        FirebaseApp.configure()
        NotificationService.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
