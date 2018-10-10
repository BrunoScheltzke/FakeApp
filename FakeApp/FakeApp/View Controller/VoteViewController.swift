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
    @IBOutlet weak var trueButton: UIButton!
    
    @IBOutlet weak var fakeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        addHideKeyboardOnTouch()
        
        fakeButton.layer.addShadow(with: #colorLiteral(red: 0.1803921569, green: 0.1803921569, blue: 0.1803921569, alpha: 1), alpha: 0.23, xOffset: 0, yOffset: 0, blur: 10, spread: 0)
        trueButton.layer.addShadow(with: #colorLiteral(red: 0.1803921569, green: 0.1803921569, blue: 0.1803921569, alpha: 1), alpha: 0.23, xOffset: 0, yOffset: 0, blur: 10, spread: 0)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func voteTrueButtonTapped(_ sender: Any) {
        guard var url = newsURLTextField.text else {
            self.present(message: "Insira a url da notícia")
            return
        }
        
        if url.first! == "w" {
            url = "https://" + url
        }
        
        guard let validURL = URL(string: url),
            UIApplication.shared.canOpenURL(validURL) else {
                present(message: "Essa url não parece válida.")
                return
        }
        
        vote("True", for: url)
    }
    
    @IBAction func voteFalseButtonTapped(_ sender: Any) {
        guard let url = newsURLTextField.text else {
            self.present(message: "Insira a url da notícia")
            return
        }
        
        vote("False", for: url)
    }
    
    func vote(_ vote: String, for url: String) {
        FakeApiConnector.shared.vote(vote, forNews: url) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.present(message: "Obrigado por dar a sua opinião!")
                } else {
                    self.present(message: error?.localizedDescription ?? "Ops, deu algo errado :(")
                }
                self.newsURLTextField.text = ""
            }
        }
    }
}
