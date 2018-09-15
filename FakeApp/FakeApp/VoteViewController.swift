//
//  ViewController.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/09/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class VoteViewController: UIViewController {
    @IBOutlet weak var newsURLTextField: UITextField!
    @IBOutlet weak var voteTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHideKeyboardOnTouch()
        
        view.lock()
        FakeApiConnector.shared.createUser { [unowned self] (success, error) in
            self.view.unlock()
        }
    }
    
    @IBAction func addVoteButtonTapped(_ sender: Any) {
        guard let vote = voteTextField.text,
            let newsURL = newsURLTextField.text else {
                present(message: "You need to enter both texts")
                return
        }
        
        FakeApiConnector.shared.vote(vote, forNews: newsURL) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.present(message: "Great! Vote added")
                } else {
                    self.present(message: error?.localizedDescription ?? "Something wrong happened")
                }
                
                self.voteTextField.text = ""
                self.newsURLTextField.text = ""
            }
        }
    }
}
