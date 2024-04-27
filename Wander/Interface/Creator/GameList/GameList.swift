//
//  ViewController.swift
//  Wander
//
//  Created by Alex Cabrera on 2/26/24.
// 

import UIKit
import CoreData

class GameList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var createNewGameButton: UIButton!
    @IBOutlet weak var allGamesTableView: UITableView!
    
    var textCellIdentifier = "GameCell"
    let segueID = "GameTitleSegueIdentifier"
    var gameList:[StoredGame] = []
    var user:StoredUser?
    var selectedGameIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        allGamesTableView.delegate = self
        allGamesTableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if GlobalInfo.currentUser != nil {
            user = GlobalInfo.currentUser
        } else {
            user = StoredUser(context: managedContext, username: "generic@utexas.edu", id: "bIbGX3waQMdkkfBnvF61uEWuWsI2")
        }
        
        createNewGameButton.backgroundColor = Color.primary
        createNewGameButton.tintColor = .white
                
        gameList = user?.fetchAllGames() ?? []
        self.navigationItem.title = "Create"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            
            let deleteAlertVC = UIAlertController(
                title: "Are you sure?",
                message: "If you delete the game \"\(self.gameList[indexPath.row].name!)\", it cannot be undone.",
                preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                (alert) in
                _ = self.user?.deleteGame(game: self.gameList[indexPath.row])
                self.gameList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                handler(true)
            })
            deleteAlertVC.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            deleteAlertVC.addAction(cancelAction)
            
            self.present(deleteAlertVC, animated: true)
            
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nextVC = segue.destination as? GameView {
            nextVC.delegate = self
            if segue.identifier == "CreateGameSegue"{
                if let user = user {
                    let newGame = user.createGame()
                    gameList.append(newGame)
                    let idxPath = IndexPath(row: allGamesTableView.numberOfRows(inSection: 0), section: 0)
                    allGamesTableView.insertRows(at: [idxPath], with: .automatic)
                    nextVC.game = newGame
                    selectedGameIndex = idxPath
                }
                else {
                    print("user is nil")
                }
                
            } else if segue.identifier == "OpenGameSegue" {
                let gameIndex = allGamesTableView.indexPathForSelectedRow?.row
                let idxPath = IndexPath(row: gameIndex!, section: 0)
                nextVC.game = gameList[gameIndex!]
                selectedGameIndex = idxPath
            }
        }
    }
    
    func deleteGame(game: StoredGame) {
        if let gameIndex = allGamesTableView.indexPathForSelectedRow?.row {
            // Deleting game that was not just created
            let idxPath = IndexPath(row: gameIndex, section: 0)
            _ = self.user?.deleteGame(game: self.gameList[idxPath.row])
            self.gameList.remove(at: idxPath.row)
            allGamesTableView.reloadData()
        }
        else {
            // Deleting game that was just created
            _ = self.user?.deleteGame(game: game)
            self.gameList.remove(at: gameList.count - 1)
            allGamesTableView.reloadData()
        }
    }
}
