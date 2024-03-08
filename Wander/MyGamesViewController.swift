//
//  ViewController.swift
//  Wander
//
//  Created by Alex Cabrera on 2/26/24.
//

import UIKit
import CoreData

//var exampleGames:[String] = ["Cool Game #1", "Cool Game #2", "Cool Game #3"]

class MyGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var allGamesTableView: UITableView!
    
    var textCellIdentifier = "GameCell"
    let segueID = "GameTitleSegueIdentifier"
    var gameList:[StoredGame] = []
    var manager:GameManager?
    var user:StoredUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allGamesTableView.delegate = self
        allGamesTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func getUser(managedContext: NSManagedObjectContext) -> StoredUser? {
        do {
            let res = try managedContext.fetch(StoredUser.fetchRequest())
            return res.count > 0 ? res[0] : nil
        }
        catch {
            return nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
             return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        manager = GameManager(context: managedContext)
        gameList = manager?.fetchAllGames() ?? []
        if let appUser = getUser(managedContext: managedContext) {
            user = appUser
        } else {
            user = StoredUser(context: managedContext, username: "testUser")
        }
        allGamesTableView.reloadData()
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        gameList.count
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
        let newGame = manager?.createGame(creator: user!)
        gameList.append(newGame!)
        allGamesTableView.reloadData()
    }
}
