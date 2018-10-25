//
//  NewsCardTableViewCell.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class NewsCardTableViewCell: UITableViewCell {
    @IBOutlet weak var stackHeight: UIStackView!
    
    @IBOutlet weak var fakeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fakeView: UIView!
    @IBOutlet weak var factView: UIView!
    @IBOutlet weak var factHeightConstraint: NSLayoutConstraint!
    
    var hasFetchedPreview: Bool = false
    @IBOutlet weak var hasVotedLabel: UILabel!
    
    var news: News! {
        didSet {
            factHeightConstraint.constant = 0
            fakeHeightConstraint.constant = 0
            
            hasVotedLabel.text = ""
            hasVotedLabel.backgroundColor = .clear
            
            title.text = "Notícia encontrada"
            portal.text = "Carregando detalhes"
            colorView.backgroundColor = .clear
            
            if !hasFetchedPreview && news.portal == nil {
                self.cardView.lock()
                FakeApiConnector.shared.requestPreview(of: news) { [unowned self] (resultNews, error) in
                    self.hasFetchedPreview = true
                    self.cardView.unlock()
                    DispatchQueue.main.async {
                        if let result = resultNews {
                            self.news = result
                        }
                    }
                }
            } else {
                if news.reliabilityIndex == .neutral {
                    fakeView.backgroundColor = ReliabilityIndex.fake.color
                    factView.backgroundColor = ReliabilityIndex.fact.color
                    
                    let percentageOfFake = CGFloat(news.voters.filter { $0.vote == false }.count)/50
                    let percentageOfFact = CGFloat(news.voters.filter { $0.vote == true }.count)/50
                    
                    let height = stackHeight.bounds.height
                    
                    factHeightConstraint.constant = height * percentageOfFact
                    fakeHeightConstraint.constant = height * percentageOfFake
                    
                    UIView.animate(withDuration: 0.3) {
                        self.layoutSubviews()
                    }
                }
                
                if let newsTitle = news.title {
                    title.text = newsTitle
                } else {
                    title.text = "Notícia encontrada"
                }
                
                if let portalName = news.portal?.name {
                    portal.text = "Portal: " + portalName
                } else {
                    portal.text = "Clique para ver detalhes"
                }
                
                if let userVote = FakeApiConnector.shared.getUserVote(on: news) {
                    let vote = userVote.vote ? "Fato" : "Fake"
                    let color = userVote.vote ? ReliabilityIndex.fact.color : ReliabilityIndex.fake.color
                    
                    hasVotedLabel.text = "Votou \(vote)"
                    hasVotedLabel.backgroundColor = color
                }
                
                colorView.backgroundColor = news.reliabilityIndex.color
                self.layoutIfNeeded()
            }
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hasFetchedPreview = false
    }
}
