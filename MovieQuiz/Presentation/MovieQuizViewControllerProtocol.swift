//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 15.01.2025.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func enableActionButtons()
    
    func showAlert(alert: UIAlertController)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func resetImageBorderWidth()
}
