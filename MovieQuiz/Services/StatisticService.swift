//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 26.12.2024.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int = 0
    
    var bestGame: GameResult = GameResult(correct: <#Int#>, total: <#Int#>, date: <#Date#>)
    
    var totalAccuracy: Double = 0.0
    
    func store(correct count: Int, total amount: Int) {
        
    }
    
    
}
