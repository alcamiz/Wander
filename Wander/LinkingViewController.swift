//
//  LinkingViewController.swift
//  Wander
//
//  Created by Nihar Rao on 3/15/24.
//

import UIKit

class LinkingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var allTilesTableView: UITableView!
    @IBOutlet weak var linkingNavigationItem: UINavigationItem!
    
    
    var linkTitle: String!
    var tileList:[StoredTile] = []
    var textCellIdentifier = "TileCell"
    var parentTile:StoredTile?
    var delegate:EditorViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTilesTableView.delegate = self
        allTilesTableView.dataSource = self
        
        linkingNavigationItem.title = "Link for \(linkTitle ?? "ERROR")"
        tileList = parentTile?.game?.fetchAllTiles() ?? []

        // Do any additional setup after loading the view.
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
        cell.textLabel?.text = tileList[row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTile = tileList[indexPath.row]
        
        switch (linkTitle) {
            case "Button One":
                delegate?.button1Option?.child = selectedTile
                try? parentTile?.managedObjectContext?.save()
                self.dismiss(animated: true)
            case "Button Two":
                delegate?.button2Option?.child = selectedTile
                try? parentTile?.managedObjectContext?.save()
                self.dismiss(animated: true)
            default:
                break
        }
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
