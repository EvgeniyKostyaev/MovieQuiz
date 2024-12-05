import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    private var questions: [QuizQuestion] = []
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questions = createQuizQuestions()
        
        let currentQuestion = questions[currentQuestionIndex]
        let currentStep = convert(model: currentQuestion)

        show(quiz: currentStep)
    }
    
    // MARK: - Helper methods
    private func createQuizQuestions() -> [QuizQuestion] {
        var quizQuestions: [QuizQuestion] = []
        
        let godfatherQuestion = QuizQuestion.init(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true)
        quizQuestions.append(godfatherQuestion)
        
        let darkKnightQuestion = QuizQuestion.init(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true)
        quizQuestions.append(darkKnightQuestion)
        
        let killBillQuestion = QuizQuestion.init(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true)
        quizQuestions.append(killBillQuestion)
        
        let avengersQuestion = QuizQuestion.init(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true)
        quizQuestions.append(avengersQuestion)
        
        let deadpoolQuestion = QuizQuestion.init(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true)
        quizQuestions.append(deadpoolQuestion)
        
        let greenKnightQuestion = QuizQuestion.init(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true)
        quizQuestions.append(greenKnightQuestion)
        
        let oldQuestion = QuizQuestion.init(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
        quizQuestions.append(oldQuestion)
        
        let iceAgedQuestion = QuizQuestion.init(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
        quizQuestions.append(iceAgedQuestion)
        
        let teslaQuestion = QuizQuestion.init(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
        quizQuestions.append(teslaQuestion)
        
        let vivariumQuestion = QuizQuestion.init(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
        quizQuestions.append(vivariumQuestion)
        
        return quizQuestions
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStepViewModel = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                                                  question: model.text,
                                                  questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
                                                  
        return quizStepViewModel
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            let currentQuestion = self.questions[self.currentQuestionIndex]
            let currentStep = self.convert(model: currentQuestion)

            self.show(quiz: currentStep)
        }

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if (isCorrect) {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
           self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let results = QuizResultsViewModel(title: "Этот раунд окончен!",
                                               text: "Ваш результат: \(correctAnswers)/\(questions.count)",
                                               buttonText: "Сыграть еще раз")
            
            show(quiz: results)
        } else {
            currentQuestionIndex += 1
            
            let nextQuestion = questions[currentQuestionIndex]
            let nextStep = convert(model: nextQuestion)
            
            show(quiz: nextStep)
        }
        
        resetImageBorderWidth()
    }
    
    private func resetImageBorderWidth() {
        imageView.layer.borderWidth = 0
    }
    
    // MARK: - Action methods
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
}

struct QuizQuestion {
  // строка с названием фильма,
  // совпадает с названием картинки афиши фильма в Assets
  let image: String
  // строка с вопросом о рейтинге фильма
  let text: String
  // булевое значение (true, false), правильный ответ на вопрос
  let correctAnswer: Bool
}

struct QuizStepViewModel {
  // картинка с афишей фильма с типом UIImage
  let image: UIImage
  // вопрос о рейтинге квиза
  let question: String
  // строка с порядковым номером этого вопроса (ex. "1/10")
  let questionNumber: String
}

struct QuizResultsViewModel {
  // строка с заголовком алерта
  let title: String
  // строка с текстом о количестве набранных очков
  let text: String
  // текст для кнопки алерта
  let buttonText: String
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
