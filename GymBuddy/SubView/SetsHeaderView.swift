//
//  ExerciseHeaderView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//


import SwiftUI

struct SetsHeaderView: View {
    let exerciseType: ExerciseType
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Text("SET")
                .frame(width: 50)
            if exerciseType == .strength {
                Text("KG")
                    .frame(minWidth: 80)
                Text("REPS")
                    .frame(minWidth: 80)
            } else {
                Text("KM")
                    .frame(minWidth: 80)
                Text("MIN")
                    .frame(minWidth: 80)
            }
        }
        .font(.caption)
        .foregroundColor(.gray)
        .padding(.bottom, 5)
    }
}
