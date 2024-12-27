import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterTitleLabel: UILabel!
    @IBOutlet private var counterValueLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    private var correctAnswers = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFonts()
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        self.statisticService = StatisticService()
        
        self.questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Helper methods
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStepViewModel = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
                                                  
        return quizStepViewModel
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterValueLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if (isCorrect) {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [ weak self ] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            let message = getAlertMessage()
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть еще раз",
                completion: {
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    
                    self.questionFactory?.requestNextQuestion()
                }
            )
            
            self.alertPresenter?.showAlert(alertModel: alertModel)
        } else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
        
        resetImageBorderWidth()
        enableActionButtons()
    }
    
    private func getAlertMessage() -> String {
        var message = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        
        if let gamesCount = statisticService?.gamesCount {
            message.append("\nКоличество сыгранных квизов: \(gamesCount)")
        }
        
        if let bestGame = statisticService?.bestGame {
            message.append("\nРекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))")
        }
        
        if let totalAccuracy = statisticService?.totalAccuracy {
            message.append("\nСредняя точность: \(totalAccuracy)%")
        }
        
        return message
    }
    
    private func resetImageBorderWidth() {
        imageView.layer.borderWidth = 0
    }
    
    private func setupFonts() {
        counterTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        counterValueLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23.0)
        
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
    }
    
    private func disableActionButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    private func enableActionButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    // MARK: - Action methods
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        disableActionButtons()
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        disableActionButtons()
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    // MARK: QuestionFactoryDelegate methods
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
            
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - AlertPresenterDelegate methods
    
    func didShowAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}
