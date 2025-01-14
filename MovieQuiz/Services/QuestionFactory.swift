//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 17.12.2024.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    weak var delegate: QuestionFactoryDelegate?
    
    private let moviesLoader: MoviesLoading = MoviesLoader()
    
    private var movies: [MostPopularMovie] = []
    
    private var retryCount = 7
    
    func requestNextQuestion() {
         
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()

            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image: \(error.localizedDescription)")
                
                if retryCount > 0 {
                    retryCount -= 1
                    
                    self.requestNextQuestion()
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.didFailToLoadData(errorMessage: "Не удалось загрузить изображение после нескольких попыток")
                    }
                }
                
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let randomRaiting = Float.random(in: 7...9)
            
            let text = "Рейтинг этого фильма больше, чем \(Int(randomRaiting))?"
            
            let correctAnswer = rating > randomRaiting
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch (result) {
                case .success(let mostPopularMovies):
                    self.handleSuccess(mostPopularMovies)
                case .failure(let error):
                    self.delegate?.didFailToLoadData(errorMessage: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helper methods
    private func handleSuccess(_ mostPopularMovies: MostPopularMovies) {
        if !mostPopularMovies.errorMessage.isEmpty {
            self.delegate?.didFailToLoadData(errorMessage: mostPopularMovies.errorMessage)
            return
        }
        
        self.movies = mostPopularMovies.items
        
        if self.movies.isEmpty {
            self.delegate?.didFailToLoadData(errorMessage: "Список фильмов пуст")
        } else {
            self.delegate?.didLoadDataFromServer()
        }
    }
}

