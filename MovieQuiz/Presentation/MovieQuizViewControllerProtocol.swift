//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 15.01.2025.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showAlert(alertModel: AlertModel)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func enableActionButtons()
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func resetImageBorderWidth()
}
