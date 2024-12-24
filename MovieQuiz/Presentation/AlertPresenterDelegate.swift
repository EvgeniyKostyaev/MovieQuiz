//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Evgeniy Kostyaev on 24.12.2024.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    
    func didShowAlert(alert: UIAlertController)
    
}
