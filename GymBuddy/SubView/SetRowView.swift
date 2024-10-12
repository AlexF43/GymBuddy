//
//  SetRowView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 10/10/2024.
//

import SwiftUI

struct SetRowView: View {
    @Binding var set: ExerciseSet
    let setNumber: Int
    @FocusState.Binding var focusedField: String?
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Text("\(setNumber)")
                .frame(width: 50)
                .font(.headline)
            
            switch set.data {
            case .strength(reps: let reps, weight: let weight):
                TextField("0", value: Binding(
                    get: { weight },
                    set: { set.data = .strength(reps: reps, weight: $0) }
                ), formatter: NumberFormatter())
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 80)
                .focused($focusedField, equals: "weight_\(set.id)")
                
                TextField("0", value: Binding(
                    get: { reps },
                    set: { set.data = .strength(reps: $0, weight: weight) }
                ), formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 80)
                .focused($focusedField, equals: "reps_\(set.id)")
                
            case .cardio(distance: let distance, time: let time):
                TextField("0.0", value: Binding(
                    get: { distance },
                    set: { set.data = .cardio(distance: $0, time: time) }
                ), formatter: NumberFormatter())
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 80)
                .focused($focusedField, equals: "distance_\(set.id)")
                
                TextField("0", value: Binding(
                    get: { Int(time) },
                    set: { set.data = .cardio(distance: distance, time: TimeInterval($0)) }
                ), formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 80)
                .focused($focusedField, equals: "time_\(set.id)")
            }
        }
    }
}
