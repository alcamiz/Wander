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
        // Do any additional setup after loading the view.
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
