//
//  ResultView.swift
//  Wander
//
//  Created by Alex Cabrera on 4/4/24.
//

import UIKit

class ResultView: UITableViewController {
        
    var query: String = ""
    var selectedFilter: String?
    var selectedSort: String?
    
    // TODO: Change to FirebaseGame
    var queriedGames: [StoredGame] = []
    var tableCellId = ""

    var localSuperView: UIViewController?
    var debug = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableCellId = UUID().uuidString
        tableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: self.tableCellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: Load queried games (FirebaseGame), using query, filter, sort
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !debug {
            return queriedGames.count
        }
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.tableCellId, for: indexPath) as! ResultCell

        // TODO: Change to FirebaseGame
        if !debug {
            let curGame = queriedGames[indexPath.row]
            cell.titleLabel.text = curGame.name ?? "Untitled"
            cell.authorLabel.text = curGame.author?.username ?? "Unknown"
//            cell.imageScreen.image = if curGame.image != nil {
//                UIImage.init(data: curGame.image!)
//            } else {
//                UIImage(systemName: "italic")
//            }
        } else {
            cell.titleLabel.text = "Untitled"
            cell.authorLabel.text = "Unknown"
            cell.imageScreen.image = UIImage(systemName: "italic")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "GameScreen", bundle: nil)
        let gameScreen = storyboard.instantiateViewController(withIdentifier: "GameScreen") as! GameScreen
        
        // TODO: Change to FirebaseGame
        if !debug {
            gameScreen.game = queriedGames[indexPath.row]
        }
        
        self.localSuperView?.navigationController?.pushViewController(gameScreen, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
}
