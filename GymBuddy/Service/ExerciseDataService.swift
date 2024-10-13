//
//  ExerciseDataService.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

import Foundation

/// get exercises from csv file for use in exercise searching
func readExercisesFromCSV() -> [SampleExercise] {
    // get file location
    guard let fileURL = Bundle.main.url(forResource: "CommonExercises", withExtension: "csv") else {
        print("CSV file not found")
        return []
    }
    
    do {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)
        
        // skip headder in csv
        let dataLines = lines.dropFirst()
        
        // map csv data to sample exercise
        return dataLines.compactMap { line in
            let items = line.components(separatedBy: ",")
            guard items.count >= 4 else { return nil }
            
            let name = items[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let imgURL = items[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let targetMuscle = items[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let typeString = items[3].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            guard !name.isEmpty && !targetMuscle.isEmpty else { return nil }
            
            let type: ExerciseType = typeString == "cardio" ? .cardio : .strength
            
            return SampleExercise(name: name,
                                  imgURL: imgURL.isEmpty ? "" : imgURL,
                                  targetMuscle: targetMuscle,
                                  type: type)
        }
    } catch {
        print("Error reading CSV file: \(error.localizedDescription)")
        return []
    }
}
