//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 26.12.2024.
//

import Foundation

private enum Keys: String {
    case gamesCount
    case bestGameCorrect
    case bestGameTotal
    case bestGameDate
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
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double = 0.0
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        if (count >= bestGame.correct) {
            bestGame = GameResult(correct: count, total: amount, date: Date())
        }
    }
    
}
