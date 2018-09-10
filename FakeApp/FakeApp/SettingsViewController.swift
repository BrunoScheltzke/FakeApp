//
//  SettingsViewController.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/09/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var apiPathTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHideKeyboardOnTouch()
    }
    
    @IBAction func setApiButtonTapped(_ sender: Any) {
        FakeApiConnector.shared.apiIP = apiPathTextField.text ?? ""
        
        present(message: "Ip set: \(FakeApiConnector.shared.apiIP)")
    }
}
