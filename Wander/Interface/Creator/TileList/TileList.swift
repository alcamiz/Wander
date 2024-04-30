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
    var textCellIdentifier = "NewCell"
    var createButton: UIBarButtonItem?
    
    @IBOutlet weak var allTilesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        self.navigationItem.backBarButtonItem = backItem
        
        allTilesTableView.register(UINib(nibName: "NewCell", bundle: nil), forCellReuseIdentifier: "NewCell")

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
    
    // Display TableView in form of NewCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! NewCell
        let row = indexPath.row
        let currentTile = tileList[row]
        
        // tile's title (for origin tile and end tiles)
        if currentTile.title == nil || currentTile.title?.count == 0 {
            cell.titleLabel.text = "Untitled"
        } else {
            cell.titleLabel.text = currentTile.title!
        }
        
        // tile's type
        if currentTile.getType() == TileType.root {
            cell.statusLabel.text = "Origin Tile"
        }
        else if currentTile.getType() == TileType.win {
            cell.statusLabel.text = "Win Tile"
        }
        else if currentTile.getType() == TileType.lose {
            cell.statusLabel.text = "Lose Tile"
        }
        else {
            cell.statusLabel.text = "Normal Tile"
        }

        // display tile's image
        let currentTileImage = currentTile.fetchImage()
        if currentTileImage != nil {
            cell.imageScene.image = currentTileImage
            cell.imageScene.contentMode = .scaleAspectFill
        }
        else {
            cell.imageScene.image = UIImage(systemName: "questionmark")
            cell.imageScene.contentMode = .scaleAspectFit
        }
        
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
