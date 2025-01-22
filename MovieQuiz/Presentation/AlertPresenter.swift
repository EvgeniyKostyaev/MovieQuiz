//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 24.12.2024.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        
        alert.view.accessibilityIdentifier = "GameResultsAlert"

        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }

        alert.addAction(action)
        
        delegate?.didShowAlert(alert: alert)
    }
    
}
