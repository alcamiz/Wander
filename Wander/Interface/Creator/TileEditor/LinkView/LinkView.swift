//
//  LinkingView.swift
//  Wander
//
//  Created by Nihar Rao on 3/15/24.
//

import UIKit

class LinkView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var allTilesTableView: UITableView!
    
    var selectAction: ((StoredTile?) -> Void)?
    var linkTitle: String!
    var tileList:[StoredTile] = []
    
    var textCellIdentifier = "NewCell"
    var parentTile:StoredTile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTilesTableView.delegate = self
        allTilesTableView.dataSource = self
        tileList = parentTile?.game?.fetchAllTiles() ?? []
        allTilesTableView.register(UINib(nibName: "NewCell", bundle: nil), forCellReuseIdentifier: "NewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tileList.count
    }
    
    // Display TableView in form of TileCells
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTile = tileList[indexPath.row]
        if selectAction != nil {
            selectAction!(selectedTile)
        }
        self.navigationController?.popViewController(animated: true)
    }
}
