//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 15.01.2025.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    weak var viewController: MovieQuizViewController?
    
    let questionsAmount: Int = 10
    
    var currentQuestion: QuizQuestion?
    
    var questionFactory: QuestionFactoryProtocol?
    
    var statisticService: StatisticServiceProtocol?
    
    var alertPresenter: AlertPresenterProtocol?
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers = 0
    
    init() {
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        loadData()
    }
    
    func loadData() {
        viewController?.showLoadingIndicator()
        self.questionFactory?.loadData()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if (isCorrectAnswer) {
            correctAnswers += 1
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStepViewModel = QuizStepViewModel(
            image: UIImage(data: model.image)  ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
                                                  
        return quizStepViewModel
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func showNextQuestionOrResults() {
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
    
    // MARK: - Helper methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
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
        viewController?.showNetworkError(message: errorMessage)
    }
}
