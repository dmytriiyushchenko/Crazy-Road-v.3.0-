//
//  ResultsManager.swift
//  Crazy Road
//
//  Created by Dmytrii  on 28.11.2025.
//

import Foundation

class ResultsManager {
    
    // MARK: - Singleton

    static let shared = ResultsManager()
    private init() {}
    
    // MARK: - Properties
   
    private let resultsKey = "gameResults"
    
    // MARK: - Save
    
    func saveResult(time: Double) {
        let newResult = GameResult(time: time, date: Date())
        var results = loadResults()

        results.append(newResult)
        
        results.sort { $0.time > $1.time }
        
        guard let encoded = try? JSONEncoder().encode(results) else {
            return
        }
        
        UserDefaults.standard.set(encoded, forKey: resultsKey)
    }
    
    // MARK: - Load
    
    func loadResults() -> [GameResult] {
        
        guard let data = UserDefaults.standard.data(forKey: resultsKey) else {
            return []
        }
        
        guard let results = try? JSONDecoder().decode([GameResult].self, from: data) else {
            return []
        }
        return results
    }
    
    // MARK: - Clear
    
    func clearResults() {
        UserDefaults.standard.removeObject(forKey: resultsKey)
    }
}
