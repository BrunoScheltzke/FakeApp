//
//  TitleTableViewCell.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class TitleTableViewCell: UITableViewCell {
    var news: News! {
        didSet {
            if let newsTitle = news.title {
                title.text = newsTitle
            } else {
                title.text = "Clique no botão 'Ler notícia' para ver detalhes"
            }
            
            if let portalName = news.portal?.name {
                portal.text = "Portal: " + portalName
            } else {
                portal.text = ""
            }
            
            colorView.backgroundColor = news.reliabilityIndex.color
        }
    }
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var portal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
