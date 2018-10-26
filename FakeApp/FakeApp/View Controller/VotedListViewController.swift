//
//  VotedListViewController.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 25/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

private let displayNewsSegue = "displayNewsSegue"

class VotedListViewController: UIViewController {
    var news = [News]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        self.view.lock()
        FakeApiConnector.shared.getVotedNews(completion: { (news, error) in
            self.view.unlock()
            self.news = news ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            if let error = error {
                self.present(message: error.localizedDescription)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        
        //updates with updated news
        if let pubKey = FakeApiConnector.shared.encryptionManager.getPublicKey().key {
            let cachedNews = FakeApiConnector.shared
                                .cacheNews
                                .values.filter {
                                    $0.voters.contains(where: { uservote -> Bool in
                                        uservote.publicKey == pubKey
                                    })
                                }
            self.news = cachedNews
            tableView.reloadData()
        } else {
            let newsUrls = news.map { $0.url }
            news = []
            newsUrls.forEach { url in
                if let newsCached = FakeApiConnector.shared.cacheNews[url] {
                    news.append(newsCached)
                }
            }
            if news.count != 0 { tableView.reloadData() }
        }
    }
    
    func setupTableView() {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(type: NewsCardTableViewCell.self)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let news = sender as? News,
            let vc = segue.destination as? NewsDetailViewController {
            vc.news = news
        }
    }
}

extension VotedListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsCardTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        let news = self.news[indexPath.row]
        
        cell.news = news
        return cell
    }
}

extension VotedListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? NewsCardTableViewCell {
            performSegue(withIdentifier: displayNewsSegue, sender: cell.news)
        }
    }
}
