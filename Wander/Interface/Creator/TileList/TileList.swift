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
    var createButton: UIBarButtonItem?
    
    @IBOutlet weak var allTilesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        self.navigationItem.backBarButtonItem = backItem
        
        if self.navigationController != nil {
            createButton = UIBarButtonItem(title: "Create")
            createButton?.target = self
            createButton?.action = #selector(createTile)

            self.navigationItem.rightBarButtonItem = createButton
            self.navigationItem.leftBarButtonItem?.title = "Cancel"
        }
        
        allTilesTableView.delegate = self
        allTilesTableView.dataSource = self
        
        tileList = game?.fetchAllTiles() ?? []
        self.navigationItem.title = "Tile List"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        allTilesTableView.reloadData()
    }
    
    @objc
    func createTile() {
        let storyboard = UIStoryboard(name: "TileEditor", bundle: nil)
        let editorView = storyboard.instantiateViewController(withIdentifier: "TileEditor") as! TileEditor
        editorView.storedGame = self.game
        
        editorView.createHandler = { tile in
            guard tile != nil else {
                return
            }
            self.tileList.append(tile!)
        }
        self.navigationController?.pushViewController(editorView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tileList.count
    }
    
    // Display TableView in form of TileCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! TileCell
        let row = indexPath.row
        let currentTile = tileList[row]
        
        // tile's title (for origin tile and end tiles)
        cell.titleLabel.text = currentTile.title!
        
        // tile's type
        if currentTile.getType().rawValue == TileType.root.rawValue {
            cell.typeLabel.text = "ORIGIN TILE"
        }
        else if currentTile.getType().rawValue == TileType.win.rawValue {
            cell.typeLabel.text = "WIN TILE"
        }
        else if currentTile.getType().rawValue == TileType.lose.rawValue {
            cell.typeLabel.text = "LOSE TILE"
        }
        
        // tile's children (NOT for end tiles)
        if currentTile.getType().rawValue != TileType.win.rawValue && currentTile.getType().rawValue != TileType.lose.rawValue {
            let tileChildren = currentTile.fetchAllChildren()
            // set first child
            if let firstChild = tileChildren[0] {
                cell.firstLinkLabel.text = firstChild.title!
            }
            else {
                return
            }
            // set second child
            if let secondChild = tileChildren[1] {
                cell.secondLinkLabel.text = secondChild.title!
            }
            else {
                return
            }
        }
        
        // tile's image
        cell.tileCellImageView.image = currentTile.fetchImage()
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TileEditor", bundle: nil)
        let editorView = storyboard.instantiateViewController(withIdentifier: "TileEditor") as! TileEditor
        
        editorView.storedTile = tileList[indexPath.row]
        editorView.updateHandler = { _ in
            self.allTilesTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        self.navigationController?.pushViewController(editorView, animated: true)
    }
}
