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
    
    var textCellIdentifier = "TileCell"
    var parentTile:StoredTile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTilesTableView.delegate = self
        allTilesTableView.dataSource = self
        tileList = parentTile?.game?.fetchAllTiles() ?? []
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tileList.count
    }
    
    // Display TableView in form of TileCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TileCell", for: indexPath) as! TileCell
        let row = indexPath.row
        let currentTile = tileList[row]
        
        // tile's title (for origin tile and end tiles)
        cell.titleLabel.text = currentTile.title!
        
        // tile's type
        if currentTile.getType().rawValue == TileType.root.rawValue {
            cell.typeLabel.text = "ORIGIN"
        }
        else if currentTile.getType().rawValue == TileType.win.rawValue {
            cell.typeLabel.text = "WIN"
        }
        else if currentTile.getType().rawValue == TileType.lose.rawValue {
            cell.typeLabel.text = "LOSE"
        }
        
        // tile's children (NOT for end tiles)
        if currentTile.getType().rawValue != TileType.win.rawValue && currentTile.getType().rawValue != TileType.lose.rawValue {
            let tileChildren = currentTile.fetchAllChildren()
            // set first child
            if let firstChild = tileChildren[0] {
                cell.firstLinkLabel.text = firstChild.title!
            }
            else {
                cell.firstLinkLabel.text = "No first link"
            }
            // set second child
            if let secondChild = tileChildren[1] {
                cell.secondLinkLabel.text = secondChild.title!
            }
            else {
                cell.firstLinkLabel.text = "No second link"
            }
        }

        // display tile's image
        let currentTileImage = currentTile.fetchImage()
        if currentTileImage != nil {
            cell.tileCellImageView.image = currentTileImage
        }
        else {
            cell.tileCellImageView.image = UIImage(systemName: "questionmark")
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
