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
    @IBOutlet weak var allTilesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTilesTableView.delegate = self
        allTilesTableView.dataSource = self
        
        tileList = game?.fetchAllTiles() ?? []
        allTilesTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nextVC = segue.destination as? EditorViewController {

            if segue.identifier == "CreateTileSegue"{
                let newTile = game.createTile()
                tileList.append(newTile)
                let idxPath = IndexPath(row: allTilesTableView.numberOfRows(inSection: 0), section: 0)
                allTilesTableView.insertRows(at: [idxPath], with: .automatic)
                nextVC.tile = newTile

            } else if segue.identifier == "OpenTileSegue" {
                let tileIndex = allTilesTableView.indexPathForSelectedRow?.row
                nextVC.tile = tileList[tileIndex!]
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
}
