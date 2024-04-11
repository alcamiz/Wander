//
//  MapViewController.swift
//  Wander
//
//  Created by Benjamin Gordon on 2/28/24.
//

import UIKit

class TileList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var game:StoredGame?
    var tileList:[StoredTile] = []
    var textCellIdentifier = "TileCell"
    var selectedTileIndex:IndexPath?
    
    @IBOutlet weak var createTileButton: UIButton!
    
    @IBOutlet weak var allTilesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTileButton.backgroundColor = Color.primary
        createTileButton.tintColor = .white
        
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
        allTilesTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tileList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = formatCellText(tile: tileList[row])
        
//        if tileList[row].getType().rawValue == TileType.root.rawValue {
//            cell.textLabel?.text = "\(tileList[row].title!) (root)"
//        }
//        else {
//            cell.textLabel?.text = tileList[row].title
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, handler in
            
            if self.tileList[indexPath.row].type == TileType.root.rawValue {
                let alertVC = UIAlertController(
                    title: "Cannot Delete Root",
                    message: "This is the root tile, which cannot be deleted.",
                    preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true)
            }
            else {
                _ = self.game?.deleteTile (tile: self.tileList[indexPath.row])
                self.tileList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                handler(true)
            }
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func formatCellText(tile: StoredTile) -> String {
        var cellText = tile.title!
        if tile.getType().rawValue == TileType.root.rawValue {
            cellText += " \n\tROOT TILE"
        }
        else if tile.getType().rawValue == TileType.win.rawValue {
            cellText += "\n\tWIN TILE"
        }
        else if tile.getType().rawValue == TileType.lose.rawValue {
            cellText += "\n\tLOSE TILE"
        }
        let tileChildren = tile.fetchAllChildren()
        for (index, tileChild) in tileChildren.enumerated() {
            if let tileChild = tileChild {
                cellText += "\n\tButton \(index+1): \(tileChild.title!)"
            }
        }
        return cellText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nextVC = segue.destination as? EditorView {

            if segue.identifier == "CreateTileSegue"{
                let newTile = game?.createTile()
                tileList.append(newTile!)
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
}
