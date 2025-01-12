//
//  MostPopularMovie.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 12.01.2025.
//

import Foundation

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
