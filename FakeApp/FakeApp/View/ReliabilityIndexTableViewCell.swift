//
//  ReliabilityIndexTableViewCell.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class ReliabilityIndexTableViewCell: UITableViewCell {
    var news: News! {
        didSet {
            reliabilityIndex.text = news.reliabilityIndex.asString
            reliabilityIndexDescription.text = news.reliabilityIndex.description
        }
    }
    @IBOutlet weak var reliabilityIndexDescription: UILabel!
    @IBOutlet weak var reliabilityIndex: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
