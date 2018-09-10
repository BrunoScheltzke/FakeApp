//
//  VerifyNewsViewController.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/09/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class VerifyNewsViewController: UIViewController {
    @IBOutlet weak var newsURLTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHideKeyboardOnTouch()
    }
    
    @IBAction func verifyNewsButtonTapped(_ sender: Any) {
        guard let newsURL = newsURLTextField.text else { return }
        
        FakeApiConnector.shared.verifyVeracity(ofNews: newsURL) { (data, error) in
            DispatchQueue.main.async {
                if let data = data {
                    self.present(message: data.description)
                } else {
                    self.present(message: error?.localizedDescription ?? "Something wrong happened")
                }
                
                self.newsURLTextField.text = ""
            }
        }
    }
}
