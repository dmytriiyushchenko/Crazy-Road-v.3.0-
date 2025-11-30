//
//  ResultGame.swift
//  Crazy Road
//
//  Created by Dmytrii  on 28.11.2025.
//

import Foundation

struct GameResult: Codable {
    let time: Double
    let date: Date
  
    var timeString: String {
        return String(format: "%.1f", time) + "s"
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
