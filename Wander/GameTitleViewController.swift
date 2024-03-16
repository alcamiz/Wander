//
//  GameTitleViewController.swift
//  Wander
//
//  Created by Nihar Rao on 3/6/24.
//

import UIKit

class GameTitleViewController: UIViewController {
    
    var delegate:UIViewController!
    var game:StoredGame!

    @IBOutlet weak var gameTitle: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        gameTitle.text = game.name ?? "Invalid Game"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditGameSegue",
           let nextVC = segue.destination as? MapViewController {
            nextVC.game = game
        }
    }
}
