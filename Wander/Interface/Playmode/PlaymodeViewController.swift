//
//  PlaymodeViewController.swift
//  Wander
//
//  Created by Gabby G on 4/4/24.
//

import UIKit

class PlaymodeViewController: UIViewController {
    var game: StoredGame?
    var currentTile: StoredTile? // Take out
    
    //var currentTileID: UUID?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tileImageView: UIImageView!
    @IBOutlet weak var tileTextView: UITextView!
    @IBOutlet weak var tileButton1: UIButton!
    @IBOutlet weak var tileButton2: UIButton!
    
    @IBOutlet weak var completeGameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let gameObj = game {
            completeGameLabel.textColor = .red
        }
        /*else {
            let alert = UIAlertController(title: "Invalid Game", message: "game is nil", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }*/
        
        // Create a custom back button
        let exitGameButton = UIBarButtonItem(title: "Exit Game", style: .plain, target: nil, action: nil)
        exitGameButton.tintColor = .red
        
        // Set the custom back button for the previous view controller
        navigationController?.navigationBar.topItem?.backBarButtonItem = exitGameButton

        //if let tileID = currentTile?.id {
          //  displayTile(tileID: tileID)
      //  }
        if (currentTile != nil) {
            displayTile(tile: currentTile)
        }
        /*else {
            let alert = UIAlertController(title: "Invalid Tile", message: "tile ID is nil", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }*/
    }
    
    func displayTile(tile: StoredTile?) {
        //currentTileID = tileID
        guard let game = game else {
            print("game is nil")
            return
        }
        
        guard let newCurrentTile = tile else {
            print("currentTile is nil")
            return
        }
        
        currentTile = tile
        

        titleLabel.text = newCurrentTile.title
        tileImageView.image = newCurrentTile.fetchImage()
        tileTextView.text = newCurrentTile.text
        
        if newCurrentTile.type == TileType.win.rawValue || newCurrentTile.type == TileType.lose.rawValue {
            tileButton1.isHidden = true
            tileButton2.isHidden = true
            
            let winText = "You have just completed \"\(game.name!)\" and WON!! Congratulations!!"
            let loseText = "You have just completed \"\(game.name!)\"...and lost. Womp womp."
            
            completeGameLabel.text = (newCurrentTile.type == TileType.win.rawValue) ? winText : loseText
            completeGameLabel.isHidden = false
        } else {
            tileButton1.isHidden = false
            tileButton2.isHidden = false
            // Button names are option desc for button1, button 2
            tileButton1.setTitle(newCurrentTile.leftButton, for: .normal)
            tileButton2.setTitle(newCurrentTile.rightButton, for: .normal)
         
            completeGameLabel.isHidden = true
        }
    }
    
    @IBAction func button1Pressed(_ sender: Any) {
        displayTile(tile: currentTile?.leftTile)
    }
    
    @IBAction func button2Pressed(_ sender: Any) {
        displayTile(tile: currentTile?.rightTile)
    }
}
