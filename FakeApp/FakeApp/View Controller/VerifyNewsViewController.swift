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
        
        FakeApiConnector.shared.verifyVeracity(ofNews: newsURL) { (news, error) in
            DispatchQueue.main.async {
                if let news = news {
                    self.present(message: news.reliabilityIndex.asString)
                } else {
                    self.present(message: error?.localizedDescription ?? "Something wrong happened")
                }
                
                self.newsURLTextField.text = ""
            }
        }
    }
}
