//
//  VoteTableViewCell.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class VoteTableViewCell: UITableViewCell {
    var news: News!
    var delegate: VoteDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func fakeButtonTapped(_ sender: Any) {
        delegate.voted("Fake", for: news)
    }
    
    @IBAction func factButtonTapped(_ sender: Any) {
        delegate.voted("True", for: news)
    }
}

protocol VoteDelegate {
    func voted(_ vote: String, for news: News)
}
