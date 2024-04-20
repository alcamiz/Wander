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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc
    func createTile() {
        let storyboard = UIStoryboard(name: "NewEditor", bundle: nil)
        let editorView = storyboard.instantiateViewController(withIdentifier: "NewEditor") as! NewEditor
        editorView.storedGame = self.game
        
        editorView.createHandler = { tile in
            guard tile != nil else {
                return
            }
            let indexPath = IndexPath(row: self.tileList.count, section: 0)
            self.tileList.append(tile!)
            self.allTilesTableView.insertRows(at: [indexPath], with: .automatic)
            
        }
        self.navigationController?.pushViewController(editorView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tileList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = formatCellText(tile: tileList[row])
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
        let storyboard = UIStoryboard(name: "NewEditor", bundle: nil)
        let editorView = storyboard.instantiateViewController(withIdentifier: "NewEditor") as! NewEditor
        
        editorView.storedTile = tileList[indexPath.row]
        editorView.updateHandler = { _ in
            self.allTilesTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        self.navigationController?.pushViewController(editorView, animated: true)
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
}
