//
//  NewsViewController.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 09/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

private let presentNewsSegue = "presentNews"

class NewsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var news: [News] = []
    
    var searchResults: [News] = []
    var isSearching: Bool = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        
        setupTableView()
        
//        mockNewsData { (news, error) in
//            DispatchQueue.main.async {
//                self.news = news
//                self.tableView.reloadData()
//            }
//        }
        
        view.lock()
        FakeApiConnector.shared.verifyCredentials { (success, error) in
            FakeApiConnector.shared.requestTrendingNews(completion: { (news, error) in
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
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Procure a veracidade de notícias"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    func setupTableView() {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(type: NewsCardTableViewCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let news = sender as? News,
            let vc = segue.destination as? NewsDetailViewController {
                vc.news = news
        }
    }
}

extension NewsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension NewsViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.placeholder = "Procure a veracidade de notícias"
        view.unlock()
        isSearching = false
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchResults = []
        searchController.searchBar.placeholder = "Insira a url da notícia"
        isSearching = true
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard var url = searchBar.text else {
            present(message: "Insira a url de uma notícia.")
            return
        }
        
        if url.first! == "w" || url.first! == "W" {
            url = "https://" + url
        }
        
        guard let validURL = URL(string: url),
            UIApplication.shared.canOpenURL(validURL) else {
            present(message: "Essa url não parece válida.")
            return
        }
        
        view.lock()
        FakeApiConnector.shared.verifyVeracity(ofNews: url) { (news, error) in
            self.view.unlock()
            DispatchQueue.main.async {
                if let news = news {
                    self.searchResults = [news]
                } else {
                    let errorMessage = error != nil ? error!.localizedDescription : "Ops, algum erro ocorreu"
                    self.present(message: errorMessage)
                }
                self.tableView.reloadData()
            }
        }
    }
}

extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? NewsCardTableViewCell {
            performSegue(withIdentifier: presentNewsSegue, sender: cell.news)
        }
    }
}

extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  isSearching ? searchResults.count : news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsCardTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        let news = isSearching ? searchResults[indexPath.row] : self.news[indexPath.row]
        
        cell.news = news
        return cell
    }
}

func mockNewsData(completion: @escaping ([News], Error?) -> Void) {
    let globo = Portal(name: "G1")
    let news1 = News.init(portal: globo, url: "https://g1.globo.com/politica/eleicoes/2018/noticia/2018/10/09/bolsonaro-diz-que-governo-corrupto-estimula-o-crime-e-que-vai-governar-pelo-exemplo.ghtml", title: "Bolsonaro diz que governo corrupto estimula o crime e que vai 'governar pelo exemplo'", reliabilityIndex: .fact, voters: [])
    let news2 = News.init(portal: globo, url: "https://g1.globo.com/sp/sao-paulo/eleicoes/2018/noticia/2018/10/09/haddad-diz-estar-aberto-a-incorporar-propostas-de-ciro-gomes-em-programa-de-governo.ghtml", title: "Haddad diz estar 'aberto' a incorporar propostas de Ciro Gomes em programa de governo", reliabilityIndex: .neutral, voters: [UserVote.init(publicKey: "dd", vote: true),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "dd", vote: true),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "dd", vote: true),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "dd", vote: true),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "dd", vote: true),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "", vote: false),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "", vote: false),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "", vote: false),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "", vote: false),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "", vote: false),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "", vote: false),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "", vote: false),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "", vote: false),
                                                                                                                                                                                                                                                                                                                                                   UserVote.init(publicKey: "", vote: false)])
    let news3 = News.init(portal: globo, url: "https://g1.globo.com/politica/eleicoes/2018/noticia/2018/10/07/ele-nao-afirma-ciro-gomes-ao-ser-questionado-sobre-apoio-no-segundo-turno.ghtml", title: "'Ele não', afirma Ciro Gomes ao ser questionado sobre apoio no segundo turno", reliabilityIndex: .fake, voters: [])
    let news4 = News.init(portal: globo, url: "https://g1.globo.com/politica/eleicoes/2018/noticia/2018/10/07/fora-do-segundo-turno-marina-diz-que-fara-oposicao-ao-presidente-eleito.ghtml", title: "Fora do segundo turno, Marina diz que fará oposição ao presidente que for eleito", reliabilityIndex: .neutral, voters: [])
    
    completion([news1, news2, news3, news4], nil)
}
