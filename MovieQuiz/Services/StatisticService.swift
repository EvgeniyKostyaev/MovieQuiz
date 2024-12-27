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
    
    case correctAnswers
    case totalAnswers
    
    case totalAccuracy
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
    
    var totalAccuracy: Double {
        get {
            storage.double(forKey: Keys.totalAccuracy.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    private var totalAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalAnswers.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.totalAnswers.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let newGame = GameResult(correct: count, total: amount, date: Date())
        
        if (newGame.isBetterThan(bestGame)) {
            bestGame = newGame
        }
        
        correctAnswers += count
        totalAnswers += amount
        
        if (totalAnswers > 0) {
            totalAccuracy = Double((correctAnswers * 100) / totalAnswers)
        }
    }
    
}
