//
//  UIView.swift
//  Jukebox Music
//
//  Created by Bruno Scheltzke on 24/07/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

private let backGrounViewTag = 3432

extension UIView {
    func addHideKeyboardOnTouch() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
    
    
    func applyGradient(colors: [UIColor]) -> Void {
        self.applyGradient(colors, locations: nil)
    }
    
    func applyGradient(_ colors: [UIColor], locations: [NSNumber]?, cornerRadius: CGFloat = 0) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.cornerRadius = cornerRadius
        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func lock() {
        if let blockedView = self.viewWithTag(backGrounViewTag) {
            blockedView.removeFromSuperview()
        }
        
        let backGrounView = UIView()
        backGrounView.isUserInteractionEnabled = false
        backGrounView.tag = backGrounViewTag
        
        self.addSubview(backGrounView)
        backGrounView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        backGrounView.translatesAutoresizingMaskIntoConstraints = false
        
        let descHorizontal = "H:|-0-[backGrounView]-0-|"
        let descVertical = "V:|-0-[backGrounView]-0-|"
        
        let viewsDict = ["backGrounView" : backGrounView]
        
        let horizontalConstraint  = NSLayoutConstraint.constraints(withVisualFormat: descHorizontal,
                                                                   options: .init(rawValue: 0),
                                                                   metrics: nil,
                                                                   views: viewsDict)
        
        let verticalConstraint  = NSLayoutConstraint.constraints(withVisualFormat: descVertical,
                                                                 options: .init(rawValue: 0),
                                                                 metrics: nil,
                                                                 views: viewsDict)
        
        self.addConstraints(horizontalConstraint)
        self.addConstraints(verticalConstraint)
        
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
            backGrounView.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
        }, completion: nil)
    }
    
    func unlock() {
        DispatchQueue.main.async {
            guard let backGroundView = self.viewWithTag(backGrounViewTag) else {
                return
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                backGroundView.alpha = 0
            }) { (_) in
                backGroundView.removeFromSuperview()
            }
        }
    }
}
