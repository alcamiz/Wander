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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = gameList[row].name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID,
           let nextVC = segue.destination as? GameTitleViewController {
            nextVC.delegate = self
            let gameIndex = allGamesTableView.indexPathForSelectedRow?.row
            nextVC.game = gameList[gameIndex!]
        }
    }
    
    @IBAction func addGame(_ sender: Any) {
        let newGame = user?.createGame(creator: user!)
        gameList.append(newGame!)
        let idxPath = IndexPath(row: allGamesTableView.numberOfRows(inSection: 0), section: 0)
        allGamesTableView.insertRows(at: [idxPath], with: .automatic)
    }
}
