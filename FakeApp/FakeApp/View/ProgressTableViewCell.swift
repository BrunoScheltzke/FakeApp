//
//  ProgressTableViewCell.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 25/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class ProgressTableViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var fakeProgressView: UIView!
    
    @IBOutlet weak var fakeWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var factProgressView: UIView!
    @IBOutlet weak var factWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionProgress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.borderColor = UIColor.lightGray.cgColor
        backView.layer.borderWidth = 0.2
        backView.layer.cornerRadius = 8
        backView.clipsToBounds = true
        fakeProgressView.layer.addShadow(with: #colorLiteral(red: 0.1803921569, green: 0.1803921569, blue: 0.1803921569, alpha: 1), alpha: 0.23, xOffset: 0, yOffset: 0, blur: 10, spread: 0)
    }
    
    func setFactProgress(to progress: CGFloat) {
        factWidthConstraint.constant = backView.bounds.width * progress
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
    func setFakeProgress(to progress: CGFloat) {
        fakeWidthConstraint.constant = backView.bounds.width * progress
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
}
