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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.lock()
        FakeApiConnector.shared.verifyCredentials { [unowned self] (success, error) in
            self.view.unlock()
            
            DispatchQueue.main.async {
                self.setupTableView()
            }
            mockNewsData { (news, error) in
                self.news = news
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
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

extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = self.news[indexPath.row]
        
        performSegue(withIdentifier: presentNewsSegue, sender: news)
    }
}

extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsCardTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.news = news[indexPath.row]
        return cell
    }
}

func mockNewsData(completion: @escaping ([News], Error?) -> Void) {
    let globo = Portal(name: "G1")
    let news1 = News.init(portal: globo, url: "https://g1.globo.com/politica/eleicoes/2018/noticia/2018/10/09/bolsonaro-diz-que-governo-corrupto-estimula-o-crime-e-que-vai-governar-pelo-exemplo.ghtml", title: "Bolsonaro diz que governo corrupto estimula o crime e que vai 'governar pelo exemplo'", reliabilityIndex: .fact)
    let news2 = News.init(portal: globo, url: "https://g1.globo.com/sp/sao-paulo/eleicoes/2018/noticia/2018/10/09/haddad-diz-estar-aberto-a-incorporar-propostas-de-ciro-gomes-em-programa-de-governo.ghtml", title: "Haddad diz estar 'aberto' a incorporar propostas de Ciro Gomes em programa de governo", reliabilityIndex: .neutral)
    let news3 = News.init(portal: globo, url: "https://g1.globo.com/politica/eleicoes/2018/noticia/2018/10/07/ele-nao-afirma-ciro-gomes-ao-ser-questionado-sobre-apoio-no-segundo-turno.ghtml", title: "'Ele não', afirma Ciro Gomes ao ser questionado sobre apoio no segundo turno", reliabilityIndex: .fake)
    let news4 = News.init(portal: globo, url: "https://g1.globo.com/politica/eleicoes/2018/noticia/2018/10/07/fora-do-segundo-turno-marina-diz-que-fara-oposicao-ao-presidente-eleito.ghtml", title: "Fora do segundo turno, Marina diz que fará oposição ao presidente que for eleito", reliabilityIndex: .neutral)
    
    completion([news1, news2, news3, news4], nil)
}