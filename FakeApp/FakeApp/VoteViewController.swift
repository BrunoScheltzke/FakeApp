//
//  ViewController.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/09/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class VoteViewController: UIViewController {
    var newsURLTextField: UITextField = UITextField()
    var voteTextField: UITextField = UITextField()
    var voteButton: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
        addHideKeyboardOnTouch()
    }
    
    func setupViews() {
        newsURLTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newsURLTextField)
        newsURLTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        newsURLTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        newsURLTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        newsURLTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true
        
        newsURLTextField.placeholder = "News URL"
        newsURLTextField.borderStyle = .roundedRect
        
        voteTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(voteTextField)
        voteTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        voteTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        voteTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        voteTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20).isActive = true
        
        voteTextField.placeholder = "True/False"
        voteTextField.borderStyle = .roundedRect
        
        voteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(voteButton)
        voteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        voteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        voteButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        voteButton.centerYAnchor.constraint(equalTo: voteTextField.centerYAnchor, constant: 70).isActive = true
        
        voteButton.setTitle("Vote", for: .normal)
        voteButton.layer.cornerRadius = 8
        voteButton.backgroundColor = .blue
        voteButton.addTarget(self, action: #selector(addVoteButtonTapped), for: .touchUpInside)
    }
    
    @objc func addVoteButtonTapped() {
        guard let vote = voteTextField.text,
            let newsURL = newsURLTextField.text else {
                present(message: "You need to enter both texts")
                return
        }
        
        FakeApiConnector.shared.vote(vote, forNews: newsURL) { (data, error) in
            DispatchQueue.main.async {
                if let data = data {
                    self.present(message: data.description)
                } else {
                    self.present(message: error?.localizedDescription ?? "Something wrong happened")
                }
                
                self.voteTextField.text = ""
                self.newsURLTextField.text = ""
            }
        }
    }
}
