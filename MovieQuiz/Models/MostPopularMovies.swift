//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 12.01.2025.
//

import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}
