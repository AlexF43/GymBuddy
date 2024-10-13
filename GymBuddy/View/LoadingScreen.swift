//
//  LoadingScreen.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

/// loading screen for when retreiving infomation from firebase
struct LoadingScreen: View {
    var body: some View {
        VStack {
            Text("Loading, please wait")
            ProgressView()
        }
    }
}

