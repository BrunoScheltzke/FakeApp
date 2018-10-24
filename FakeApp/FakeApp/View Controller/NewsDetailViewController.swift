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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = news.reliabilityIndex.asString
        navigationController?.navigationBar.barTintColor = news.reliabilityIndex.color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
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
        self.opinarButton.setTitle(opinarButtonTitle, for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.voteCardBottomConstraint.constant = constant
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func askedToReadNews(_ sender: Any) {
        if let url = URL(string: news.url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { _ in
            }
        }
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
        vote(false, for: news)
    }
    
    @IBAction func voteTrueButtonTapped(_ sender: Any) {
        vote(true, for: news)
    }
    
    func vote(_ vote: Bool, for news: News) {
        self.view.lock()
        FakeApiConnector.shared.vote(vote, forNews: news.url) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.present(message: "Ótimo! Obrigado pela sua opinião.")
                } else {
                    self.present(message: error?.localizedDescription ?? "Ops, algo deu errado.")
                }
            }
            
            FakeApiConnector.shared.verifyVeracity(ofNews: news.url, completion: { (news, error) in
                if let news = news {
                    DispatchQueue.main.async {
                        self.news = news
                        self.tableView.reloadData()
                        self.view.unlock()
                    }
                }
            })
        }
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
            let cell = UITableViewCell()
            if let userVote = FakeApiConnector.shared.getUserVote(on: news) {
                let vote = userVote.vote ? "Fato" : "Fake"
                cell.textLabel?.text = "Você votou \(vote) para essa notícia."
            } else {
                cell.textLabel?.text = "Você ainda não votou nessa notícia."
            }
            return cell
            
        case 3:
            let cell = UITableViewCell()
            
            if news.voters.count == 0 {
                cell.textLabel?.text = "Nenhuma pessoa votou nessa notícia ainda."
            } else {
                let message = news.voters.count == 1
                    ? "Apenas uma pessoa votou nessa notícia."
                    : "\(news.voters.count) pessoas votaram nessa notícia."
                
                cell.textLabel?.text = message
            }
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

extension NewsDetailViewController: UITableViewDelegate {
}
