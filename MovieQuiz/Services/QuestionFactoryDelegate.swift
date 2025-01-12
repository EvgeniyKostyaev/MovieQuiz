//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 18.12.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
