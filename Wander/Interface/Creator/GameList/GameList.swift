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
    var gameList:[InfoGame] = []
    var user:StoredUser?
    var selectedGameIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        allGamesTableView.delegate = self
        allGamesTableView.dataSource = self
        allGamesTableView.register(UINib(nibName: "GameCell", bundle: nil), forCellReuseIdentifier: "gameCell")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if GlobalInfo.currentUser != nil {
            user = GlobalInfo.currentUser
        } else {
            user = StoredUser(context: managedContext, username: "generic@utexas.edu", id: "bIbGX3waQMdkkfBnvF61uEWuWsI2")
        }
        
        createNewGameButton.backgroundColor = Color.primary
        createNewGameButton.tintColor = .white
        
        if let storedGames = user?.fetchAllGames() {
            gameList = storedGames.map {InfoGame(storedGame: $0)}
        }
        
        if let userID = user?.id {
            Task {
                let savedIDs = gameList.map {$0.storedGame!.id!.uuidString}
                let webGames = await FirebaseHelper.nonDownloadedPublished(userID: userID, alreadySaved: savedIDs)
                var counter = 0
                FirebaseHelper.loadPictures(imageList: webGames, basepath: "gamePreviews") {(int, data) in
                    webGames[int].image = data
                    self.gameList.append(InfoGame(firebaseGame: webGames[int]))
                    counter += 1
                    if counter == webGames.count {
                        self.allGamesTableView.reloadData()
                    }
                }
            }
        }
        
        self.navigationItem.title = "Game Creator"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell", for: indexPath) as! GameCell
    
        let game = gameList[indexPath.row]
        cell.titleLabel.text = game.title
        
        if game.image == nil {
            cell.imageScene.image = UIImage(systemName: "questionmark")
            cell.imageScene.contentMode = .scaleAspectFit
        } else {
            cell.imageScene.image = game.image
            cell.imageScene.contentMode = .scaleAspectFill
        }
        var isPublished = false
        if let storedGame = game.storedGame,
           storedGame.published {
            isPublished = true
        } else if let firebaseGame = game.firebaseGame {
            isPublished = true
        }
        
        if isPublished {
            cell.statusLabel.text = "Published"
            cell.statusLabel.textColor = Color.primary
        } else {
            cell.statusLabel.text = "Unpublished"
            cell.statusLabel.textColor = .lightGray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let game = self.gameList[indexPath.row]
        var action: UIContextualAction?
        
        var isPublished = false
        if let firebaseGame = game.firebaseGame {
            isPublished = true
        } else if let storedGame = game.storedGame {
            isPublished = storedGame.published
        }
        
        if isPublished {
            action = UIContextualAction(style: .destructive, title: "Delete") { action, view, handler in
                
                let deleteAlertVC = UIAlertController(
                    title: "Notice",
                    message: "A game needs to be unpublished before it can be deleted",
                    preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
                deleteAlertVC.addAction(cancelAction)
                
                self.present(deleteAlertVC, animated: true)
                
            }
        } else {
            action = UIContextualAction(style: .destructive, title: "Delete") { action, view, handler in
                
                let deleteAlertVC = UIAlertController(
                    title: "Are you sure?",
                    message: "If you delete the game \"\(self.gameList[indexPath.row].title)\", it cannot be undone.",
                    preferredStyle: .alert)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                    (alert) in
                    if let storedGame = self.gameList[indexPath.row].storedGame {
                        _ = self.user?.deleteGame(game: storedGame)
                        self.gameList.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        handler(true)
                    }
                    
                })
                deleteAlertVC.addAction(deleteAction)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                deleteAlertVC.addAction(cancelAction)
                
                self.present(deleteAlertVC, animated: true)
                
            }
        }
        
        if action != nil {
            return UISwipeActionsConfiguration(actions: [action!])
        } else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gameIndex = indexPath.row
        let idxPath = IndexPath(row: gameIndex, section: 0)
        
        let storyboard = UIStoryboard(name: "GameView", bundle: nil)
        let gameView = storyboard.instantiateViewController(withIdentifier: "GameView") as! GameView
        
        selectedGameIndex = idxPath
        if let storedGame = gameList[gameIndex].storedGame {
            gameView.game = storedGame
            self.navigationController?.pushViewController(gameView, animated: true)
        } else if let firebaseGame = gameList[gameIndex].firebaseGame {
            Task {
                let storedGame = await firebaseGame.download(managedContext: GlobalInfo.managedContext!)
                gameList[gameIndex] = InfoGame(storedGame: storedGame)
                try! GlobalInfo.managedContext!.save()
                gameView.game = storedGame
                
                allGamesTableView.reloadRows(at: [indexPath], with: .automatic)
                if let documentID = storedGame.id?.uuidString {
                    let path = "gamePreviews/\(documentID).jpeg"
                    let reference = GlobalInfo.storage.child(path)
                    reference.getData(maxSize: (5 * 1024 * 1024)) { (data, error) in
                        if let picData = data {
                            storedGame.image = picData
                            try? GlobalInfo.managedContext?.save()
                        }
                    }
                }
                self.navigationController?.pushViewController(gameView, animated: true)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nextVC = segue.destination as? GameView {
            nextVC.delegate = self
            if segue.identifier == "CreateGameSegue"{
                if let user = user {
                    let newGame = user.createGame()
                    gameList.append(InfoGame(storedGame: newGame))
                    let idxPath = IndexPath(row: allGamesTableView.numberOfRows(inSection: 0), section: 0)
                    allGamesTableView.insertRows(at: [idxPath], with: .automatic)
                    nextVC.game = newGame
                    selectedGameIndex = idxPath
                }
                else {
                    print("user is nil")
                }
                
            }
        }
    }
    
    func deleteGame(game: StoredGame) {
        if let gameIndex = allGamesTableView.indexPathForSelectedRow?.row {
            // Deleting game that was not just created
            let idxPath = IndexPath(row: gameIndex, section: 0)
            if let storedGame = self.gameList[idxPath.row].storedGame {
                _ = self.user?.deleteGame(game: storedGame)
                self.gameList.remove(at: idxPath.row)
                allGamesTableView.reloadData()
            }
        }
        else {
            // Deleting game that was just created
            _ = self.user?.deleteGame(game: game)
            self.gameList.remove(at: gameList.count - 1)
            allGamesTableView.reloadData()
        }
    }
}
