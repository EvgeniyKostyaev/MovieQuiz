import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var counterLabelsStackView: UIStackView!
    @IBOutlet private weak var counterTitleLabel: UILabel!
    @IBOutlet private weak var counterValueLabel: UILabel!
    
    @IBOutlet private weak var actionButtonsStackView: UIStackView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
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
        
        loadData()
    }
    
    // MARK: - Helper methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let quizStepViewModel = QuizStepViewModel(
            image: UIImage(data: model.image)  ?? UIImage(),
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
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
                completion: { [weak self] in
                    
                    guard let self = self else { return }
                    
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    
                    self.showLoadingIndicator()
                    self.questionFactory?.requestNextQuestion()
                }
            )
            
            self.alertPresenter?.showAlert(alertModel: alertModel)
        } else {
            currentQuestionIndex += 1
            
            showLoadingIndicator()
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
            message.append("\nСредняя точность: \(String(format: "%.2f", totalAccuracy))%")
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
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showActionButtons() {
        actionButtonsStackView.isHidden = false
    }
    
    private func showCounterLabels() {
        counterLabelsStackView.isHidden = false
    }
    
    private func loadData() {
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                self.loadData()
            }
        )
        
        self.alertPresenter?.showAlert(alertModel: alertModel)
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
        hideLoadingIndicator()
        
        guard let question = question else { return }
            
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showCounterLabels()
            self?.show(quiz: viewModel)
            self?.showActionButtons()
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        
        showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didLoadEmptyDataFromServer(errorMessage: String) {
        hideLoadingIndicator()
        
        showNetworkError(message: errorMessage)
    }
    
    func didFailToLoadData(with error: any Error) {
        hideLoadingIndicator()
        
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - AlertPresenterDelegate methods
    func didShowAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}
