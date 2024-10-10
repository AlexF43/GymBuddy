//
//  ExerciseDataService.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

import Foundation

    
func readExercisesFromCSV() -> [String] {
    guard let fileURL = Bundle.main.url(forResource: "GymExercisesDataset", withExtension: "csv") else {
        print("CSV file not found")
        return []
    }
    
    do {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)
        
        return lines.compactMap { line in
            let items = line.components(separatedBy: ",")
            var exercises = items.first?.trimmingCharacters(in: .whitespacesAndNewlines)
            return exercises?.isEmpty == false ? exercises : nil
        }
    } catch {
        print("Error reading CSV file: \(error.localizedDescription)")
        return []
    }
}
