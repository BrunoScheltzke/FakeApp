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
    var news: News!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
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
}

extension NewsDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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
        case 2:
            let cell: NewsURLTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.news = news
            return cell
        case 3:
            let cell: VoteTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.news = news
            cell.delegate = selft
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension NewsDetailViewController: VoteDelegate {
    func voted(_ vote: String, for news: News) {
        FakeApiConnector.shared.vote(vote, forNews: news.url) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.present(message: "Ótimo! Obrigado pela sua opinião.")
                } else {
                    self.present(message: error?.localizedDescription ?? "Ops, algo deu errado.")
                }
            }
        }
    }
}
extension NewsDetailViewController: UITableViewDelegate {
}
