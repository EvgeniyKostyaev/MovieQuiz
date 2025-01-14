//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 15.01.2025.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate, AlertPresenterDelegate {
    
    weak var viewController: MovieQuizViewController?
    
    private let questionsAmount: Int = 10
    
    private var currentQuestion: QuizQuestion?
    
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers = 0
    
    init() {
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        self.statisticService = StatisticService()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        loadData()
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // MARK: - Helper methods
    private func loadData() {
        viewController?.showLoadingIndicator()
        self.questionFactory?.loadData()
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if (isCorrectAnswer) {
            correctAnswers += 1
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStepViewModel = QuizStepViewModel(
            image: UIImage(data: model.image)  ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
                                                  
        return quizStepViewModel
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            
            statisticService?.store(correct: correctAnswers, total: self.questionsAmount)
            
            let message = getAlertMessage()
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    
                    guard let self = self else { return }
                    
                    self.restartGame()
                    self.correctAnswers = 0
                    
                    self.viewController?.showLoadingIndicator()
                    self.questionFactory?.requestNextQuestion()
                }
            )
            
            self.alertPresenter?.showAlert(alertModel: alertModel)
        } else {
            self.switchToNextQuestion()
            
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        didAnswer(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
            self.viewController?.resetImageBorderWidth()
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    private func getAlertMessage() -> String {
        var message = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)"
        
        if let gamesCount = statisticService?.gamesCount {
            message.append("\nКоличество сыгранных квизов: \(gamesCount)")
        }
        
        if let bestGame = statisticService?.bestGame {
            message.append("\nРекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))")
        }
        
        if let totalAccuracy = statisticService?.totalAccuracy {
            message.append("\nСредняя точность: \(String(format: "%.2f", totalAccuracy))%")
        }
        
        return message
    }
    
    // MARK: QuestionFactoryDelegate methods
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()
        viewController?.enableActionButtons()
        
        guard let question = question else { return }
            
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(errorMessage: String) {
        viewController?.hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: errorMessage,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                
                guard let self = self else { return }
                
                self.restartGame()
                
                self.loadData()
            }
        )
        
        self.alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    // MARK: - AlertPresenterDelegate methods
    func didShowAlert(alert: UIAlertController) {
        viewController?.showAlert(alert: alert)
    }
    
}
