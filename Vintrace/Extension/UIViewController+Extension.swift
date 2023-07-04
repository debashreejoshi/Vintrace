//
//  UIViewController+Extension.swift
//  Vintrace
//
//  Created by Debashree Joshi on 4/7/2023.
//

import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
