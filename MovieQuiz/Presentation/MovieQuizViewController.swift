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
    
    // MARK: - Action methods
    @IBAction private func yesButtonClicked(_ sender: UIButton) {

    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {

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
