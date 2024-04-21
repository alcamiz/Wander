//
//  ResultView.swift
//  Wander
//
//  Created by Alex Cabrera on 4/13/24.
//

import UIKit

class ResultView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var domainSelector: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var query: String = ""
    var selectedFilter: String?
    var selectedSort: String?
    var selectedDomain: String?
    
    var queriedGames: [FirebaseGame] = []
    var tableCellId = ""
    
    var localSuperView: UIViewController?
    var debug = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = false

        self.tableCellId = UUID().uuidString
        tableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: self.tableCellId)
        
        domainSelector.removeAllSegments()
        
        for (idx, title) in GlobalInfo.domainList.enumerated() {
            domainSelector.insertSegment(withTitle: title, at: idx, animated: false)
        }
        domainSelector.selectedSegmentIndex = 0
        
    }
    
    func fixSelectedRow() {
        if tableView.indexPathForSelectedRow != nil {
            tableView.deselectRow(at: tableView!.indexPathForSelectedRow!, animated: true)
        }
    }
    
    func reloadQuery() async {
        // TODO: Load queried games (FirebaseGame), using query, filter, sort
        queriedGames = await FirebaseHelper.queryGames(domain: selectedDomain, query: query, tag: selectedFilter, sort: selectedSort)
        tableView.reloadData()
        FirebaseHelper.loadPictures(imageList: queriedGames, basepath: "gamePreviews") { (index, data) in
            self.queriedGames[index].image = data
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    @IBAction func domainSelected(_ sender: Any) {
        selectedDomain = GlobalInfo.domainList[domainSelector.selectedSegmentIndex]
        Task {
            await reloadQuery()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !debug {
            return queriedGames.count
        }
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.tableCellId, for: indexPath) as! ResultCell

        // TODO: Change to FirebaseGame
        if !debug {
            let curGame = queriedGames[indexPath.row]
            cell.titleLabel.text = curGame.name
            cell.authorLabel.text = curGame.author
//            cell.imageScreen.image = if curGame.image != nil {
//                UIImage.init(data: curGame.image!)
//            } else {
//                UIImage(systemName: "italic")
//            }
        } else {
            cell.titleLabel.text = "Untitled"
            cell.authorLabel.text = "Unknown"
            cell.imageScreen.image = UIImage(systemName: "questionmark")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "GameScreen", bundle: nil)
        let gameScreen = storyboard.instantiateViewController(withIdentifier: "GameScreen") as! GameScreen
        
        // TODO: Change to FirebaseGame
        if !debug {
            gameScreen.infoGame = InfoGame(firebaseGame: queriedGames[indexPath.row])
        }

        self.localSuperView?.navigationController?.pushViewController(gameScreen, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
