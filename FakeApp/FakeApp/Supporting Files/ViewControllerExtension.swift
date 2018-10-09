//
//  Alert.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/09/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

extension UIViewController {
    func present(message: String) {
        let alert = UIAlertController(title: "FakeApp", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addHideKeyboardOnTouch() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
