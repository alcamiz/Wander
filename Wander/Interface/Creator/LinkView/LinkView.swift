//
//  LinkingViewController.swift
//  Wander
//
//  Created by Nihar Rao on 3/15/24.
//

import UIKit

class LinkView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var allTilesTableView: UITableView!
    @IBOutlet weak var linkingNavigationBar: UINavigationBar!
    @IBOutlet weak var linkingNavigationItem: UINavigationItem!
    
    
    var linkTitle: String!
    var tileList:[StoredTile] = []
    var textCellIdentifier = "TileCell"
    var parentTile:StoredTile?
    var delegate:EditorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTilesTableView.delegate = self
        allTilesTableView.dataSource = self
        
        linkingNavigationItem.title = "Link for \(linkTitle ?? "ERROR")"
        tileList = parentTile?.game?.fetchAllTiles() ?? []
        
        linkingNavigationBar.backgroundColor = Color.secondary
        linkingNavigationItem.titleView?.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //tileList = game?.getTiles() ?? []
        allTilesTableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTile = tileList[indexPath.row]
        
        if parentTile?.getType().rawValue != TileType.root.rawValue {
            parentTile?.type = TileType.between.rawValue
        }
        
        switch (linkTitle) {
            case "Button One":
                delegate?.button1Option?.child = selectedTile
                try? parentTile?.managedObjectContext?.save()
                self.navigationController?.popViewController(animated: true)
            case "Button Two":
                delegate?.button2Option?.child = selectedTile
                try? parentTile?.managedObjectContext?.save()
                self.navigationController?.popViewController(animated: true)
            default:
                break
        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
