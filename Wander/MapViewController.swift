//
//  MapViewController.swift
//  Wander
//
//  Created by Benjamin Gordon on 2/28/24.
//

import UIKit

class MapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var game:StoredGame!
    var tileList:[StoredTile] = []
    var textCellIdentifier = "TileCell"
    var selectedTileIndex:IndexPath?
    
    @IBOutlet weak var allTilesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTilesTableView.delegate = self
        allTilesTableView.dataSource = self
        
        tileList = game?.fetchAllTiles() ?? []
        allTilesTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedTileIndex != nil {
            allTilesTableView.reloadRows(at: [selectedTileIndex!], with: .automatic)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nextVC = segue.destination as? EditorViewController {

            if segue.identifier == "CreateTileSegue"{
                let newTile = game.createTile()
                tileList.append(newTile)
                let idxPath = IndexPath(row: allTilesTableView.numberOfRows(inSection: 0), section: 0)
                allTilesTableView.insertRows(at: [idxPath], with: .automatic)
                nextVC.tile = newTile
                selectedTileIndex = idxPath

            } else if segue.identifier == "OpenTileSegue" {
                let tileIndex = allTilesTableView.indexPathForSelectedRow?.row
                let idxPath = IndexPath(row: tileIndex!, section: 0)
                nextVC.tile = tileList[tileIndex!]
                selectedTileIndex = idxPath
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tileList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = tileList[row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, handler in
            _ = self.game?.deleteTile (tile: self.tileList[indexPath.row])
            self.tileList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            handler(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
