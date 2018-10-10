//
//  NewsCardTableViewCell.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class NewsCardTableViewCell: UITableViewCell {
    var news: News! {
        didSet {
            title.text = news.title
            portal.text = "Portal: " + news.portal.name
            colorView.backgroundColor = news.reliabilityIndex.color
        }
    }
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var portal: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        cardView.layer.addShadow(with: #colorLiteral(red: 0.1803921569, green: 0.1803921569, blue: 0.1803921569, alpha: 1), alpha: 0.23, xOffset: 0, yOffset: 0, blur: 10, spread: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
