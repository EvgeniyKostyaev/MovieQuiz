//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 26.12.2024.
//

import Foundation

private enum Keys: String {
    case correct
    case bestGame
    case gamesCount
}

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            if let gameResult = storage.object(forKey: Keys.bestGame.rawValue) as? GameResult {
                return gameResult
            } else {
                return GameResult(correct: 0, total: 0, date: Date())
            }
        }
        set {
            storage.set(newValue, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var totalAccuracy: Double = 0.0
    
    func store(correct count: Int, total amount: Int) {
        
    }
    
    
}
