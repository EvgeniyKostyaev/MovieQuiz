import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol, AlertPresenterDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var counterLabelsStackView: UIStackView!
    @IBOutlet private weak var counterTitleLabel: UILabel!
    @IBOutlet private weak var counterValueLabel: UILabel!
    
    @IBOutlet private weak var actionButtonsStackView: UIStackView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenterProtocol?
    
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFonts()
        
        presenter.viewController = self
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
         
        self.alertPresenter = alertPresenter
    }
    
    func show(quiz step: QuizStepViewModel) {
        showCounterLabels()
        showActionButtons()
        
        imageView.image = UIImage(data: step.imageData)  ?? UIImage()
        textLabel.text = step.question
        counterValueLabel.text = step.questionNumber
    }
    
    func showAlert(alertModel: AlertModel) {
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func enableActionButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func resetImageBorderWidth() {
        imageView.layer.borderWidth = 0
    }
    
    // MARK: - Helper methods
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
    
    private func showActionButtons() {
        actionButtonsStackView.isHidden = false
    }
    
    private func showCounterLabels() {
        counterLabelsStackView.isHidden = false
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
    
    // MARK: - AlertPresenterDelegate methods
    func didShowAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}
