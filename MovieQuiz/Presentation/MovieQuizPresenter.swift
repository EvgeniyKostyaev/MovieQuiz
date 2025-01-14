//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 15.01.2025.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    weak var viewController: MovieQuizViewController?
    
    let questionsAmount: Int = 10
    
    var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex: Int = 0
   
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
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
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
}
