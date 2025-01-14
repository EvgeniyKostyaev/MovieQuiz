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
    
    private let presenter = MovieQuizPresenter()
    
    private var questionFactory: QuestionFactoryProtocol?
    
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    private var correctAnswers = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
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
    
    func showAnswerResult(isCorrect: Bool) {
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
    
    func show(quiz step: QuizStepViewModel) {
        showCounterLabels()
        showActionButtons()
        
        imageView.image = step.image
        textLabel.text = step.question
        counterValueLabel.text = step.questionNumber
    }
    
    // MARK: - Helper methods
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let message = getAlertMessage()
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    
                    guard let self = self else { return }
                    
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    
                    self.showLoadingIndicator()
                    self.questionFactory?.requestNextQuestion()
                }
            )
            
            self.alertPresenter?.showAlert(alertModel: alertModel)
        } else {
            presenter.switchToNextQuestion()
            
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
        
        resetImageBorderWidth()
    }
    
    private func getAlertMessage() -> String {
        var message = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)"
        
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
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.loadData()
            }
        )
        
        self.alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    // MARK: - Action methods
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        disableActionButtons()
        
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        disableActionButtons()
        
        presenter.noButtonClicked()
    }
    
    // MARK: QuestionFactoryDelegate methods
    func didReceiveNextQuestion(question: QuizQuestion?) {
        hideLoadingIndicator()
        enableActionButtons()
        
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        
        showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(errorMessage: String) {
        hideLoadingIndicator()
        
        showNetworkError(message: errorMessage)
    }
    
    // MARK: - AlertPresenterDelegate methods
    func didShowAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}
