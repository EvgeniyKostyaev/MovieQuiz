//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 24.12.2024.
//

import Foundation

struct AlertModel {
    
    let title: String
    
    let message: String
    
    let buttonText: String
    
    let completion: () -> Void
    
}
