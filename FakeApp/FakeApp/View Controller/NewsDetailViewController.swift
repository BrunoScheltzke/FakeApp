//
//  NewsDetailViewController.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var voteCardView: UIView!
    @IBOutlet weak var fakeButton: UIButton!
    @IBOutlet weak var trueButton: UIButton!
    @IBOutlet weak var voteCardBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var opinarButton: UIButton!
    
    var news: News!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupViews()
    }
    
    func setupViews() {
        fakeButton.layer.addShadow(with: #colorLiteral(red: 0.1803921569, green: 0.1803921569, blue: 0.1803921569, alpha: 1), alpha: 0.23, xOffset: 0, yOffset: 0, blur: 10, spread: 0)
        trueButton.layer.addShadow(with: #colorLiteral(red: 0.1803921569, green: 0.1803921569, blue: 0.1803921569, alpha: 1), alpha: 0.23, xOffset: 0, yOffset: 0, blur: 10, spread: 0)
        
        voteCardView.layer.cornerRadius = 8
        voteCardView.layer.addShadow(with: #colorLiteral(red: 0.1803921569, green: 0.1803921569, blue: 0.1803921569, alpha: 1), alpha: 0.23, xOffset: 0, yOffset: 0, blur: 20, spread: 0)
    }
    
    @IBAction func askedToVote(_ sender: Any) {
        let shouldShowButtons = (voteCardBottomConstraint.constant == 0) ? false : true
        let opinarButtonTitle = shouldShowButtons ? "Cancelar" : "Opinar"
        let constant: CGFloat = shouldShowButtons ? 0 : -110
        
        
        UIView.animate(withDuration: 0.3) {
            self.voteCardBottomConstraint.constant = constant
            self.opinarButton.setTitle(opinarButtonTitle, for: .normal)
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func askedToReadNews(_ sender: Any) {
    }
    
    func setupTableView() {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(type: TitleTableViewCell.self)
        tableView.register(type: ReliabilityIndexTableViewCell.self)
        tableView.register(type: NewsURLTableViewCell.self)
        tableView.register(type: VoteTableViewCell.self)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func voteFakeButtonTapped(_ sender: UIButton) {
        vote("Fake", for: news)
    }
    
    @IBAction func voteTrueButtonTapped(_ sender: Any) {
        vote("True", for: news)
    }
    
    func vote(_ vote: String, for news: News) {
        self.view.lock()
        FakeApiConnector.shared.vote(vote, forNews: news.url) { (success, error) in
            DispatchQueue.main.async {
                self.view.unlock()
                if success {
                    self.present(message: "Ótimo! Obrigado pela sua opinião.")
                } else {
                    self.present(message: error?.localizedDescription ?? "Ops, algo deu errado.")
                }
            }
        }
    }
}

extension NewsDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: TitleTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.news = news
            return cell
        case 1:
            let cell: ReliabilityIndexTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.news = news
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension NewsDetailViewController: UITableViewDelegate {
}
