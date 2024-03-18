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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tileList = game?.getTiles() ?? []
        allTilesTableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "CreateTileSegue",
           let nextVC = segue.destination as? EditorViewController {
            let newTile = game.addTile()
            nextVC.tile = newTile
            tileList.append(newTile)
        } else if segue.identifier == "OpenTileSegue",
            let nextVC = segue.destination as? EditorViewController{
            let tileIndex = allTilesTableView.indexPathForSelectedRow?.row
            nextVC.tile = tileList[tileIndex!]
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
