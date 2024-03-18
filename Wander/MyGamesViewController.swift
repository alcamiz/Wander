//
//  ViewController.swift
//  Wander
//
//  Created by Alex Cabrera on 2/26/24.
//

import UIKit
import CoreData

class MyGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var allGamesTableView: UITableView!
    
    var textCellIdentifier = "GameCell"
    let segueID = "GameTitleSegueIdentifier"
    var gameList:[StoredGame] = []
    var user:StoredUser?
    var selectedGameIndex: IndexPath?
    
    func getUser(managedContext: NSManagedObjectContext) -> StoredUser? {
        let res = try? managedContext.fetch(StoredUser.fetchRequest())
        return res != nil && res!.count > 0 ? res![0] : nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allGamesTableView.delegate = self
        allGamesTableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext

        if let appUser = getUser(managedContext: managedContext) {
            user = appUser
        } else {
            user = StoredUser(context: managedContext, username: "testUser")
        }
        
        gameList = user?.fetchAllGames() ?? []
        allGamesTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedGameIndex != nil {
            allGamesTableView.reloadRows(at: [selectedGameIndex!], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = gameList[row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, handler in
            _ = self.user?.deleteGame(game: self.gameList[indexPath.row])
            self.gameList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            handler(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nextVC = segue.destination as? GameTitleViewController {
            
            if segue.identifier == "CreateGameSegue"{
                let newGame = user?.createGame()
                gameList.append(newGame!)
                let idxPath = IndexPath(row: allGamesTableView.numberOfRows(inSection: 0), section: 0)
                allGamesTableView.insertRows(at: [idxPath], with: .automatic)
                nextVC.game = newGame
                selectedGameIndex = idxPath
                
            } else if segue.identifier == "OpenGameSegue" {
                let gameIndex = allGamesTableView.indexPathForSelectedRow?.row
                let idxPath = IndexPath(row: gameIndex!, section: 0)
                nextVC.game = gameList[gameIndex!]
                selectedGameIndex = idxPath
            }
        }
    }
}
