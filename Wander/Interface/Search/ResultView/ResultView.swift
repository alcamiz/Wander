//
//  ResultView.swift
//  Wander
//
//  Created by Alex Cabrera on 4/4/24.
//

import UIKit
import Foundation
import CoreData
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

private var db = Firestore.firestore()
private var storage = Storage.storage().reference()

class ResultView: UITableViewController {
        
    var query: String = ""
    var selectedFilter: String?
    var selectedSort: String?
    
    // TODO: Change to FirebaseGame
    var queriedGames: [FirebaseGame] = []
    var tableCellId = ""

    var localSuperView: UIViewController?
    var debug = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableCellId = UUID().uuidString
        tableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: self.tableCellId)
    }
    
    func reloadQuery() async {
        // TODO: Load queried games (FirebaseGame), using query, filter, sort
        queriedGames = await FirebaseHelper.queryGames(query: query, tag: selectedFilter, sort: selectedSort)
        tableView.reloadData()
        FirebaseHelper.loadPictures(imageList: queriedGames, basepath: "gamePreviews") { (index, data) in
            self.queriedGames[index].image = data
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            cell.titleLabel.text = curGame.name
            cell.authorLabel.text = curGame.author
            cell.imageScreen.image = if curGame.image != nil {
                UIImage.init(data: curGame.image!)
            } else {
                UIImage(systemName: "italic")
            }
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
            gameScreen.infoGame = InfoGame(firebaseGame: queriedGames[indexPath.row])
        }

        self.localSuperView?.navigationController?.pushViewController(gameScreen, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
}
