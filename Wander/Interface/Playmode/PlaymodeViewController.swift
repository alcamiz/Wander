//
//  PlaymodeViewController.swift
//  Wander
//
//  Created by Gabby G on 4/4/24.
//

import UIKit

class PlaymodeViewController: UIViewController {
    var game: StoredGame?
    var currentTile: StoredTile?
    
    var currentTileID: UUID?
    var options: [StoredOption]?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tileImageView: UIImageView!
    @IBOutlet weak var tileTextView: UITextView!
    @IBOutlet weak var tileButton1: UIButton!
    @IBOutlet weak var tileButton2: UIButton!
    
    
    @IBOutlet weak var endTileView: UIView!
    @IBOutlet weak var winButton: UIButton!
    @IBOutlet weak var loseButton: UIButton!
    @IBOutlet weak var completeGameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        if let tileID = currentTile?.id {
            displayTile(tileID: tileID)
        }
        /*else {
            let alert = UIAlertController(title: "Invalid Tile", message: "tile ID is nil", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }*/
            
        endTileView.backgroundColor = Color.secondary
        completeGameLabel.textColor = .white
        winButton.setTitle("Exit Game", for: .normal)
        loseButton.setTitle("Try Again", for: .normal)
    }
    
    func displayTile(tileID: UUID) {
        currentTileID = tileID
        guard let game = game else {
            print("game is nil")
            return
        }
        
        guard let fetchedTile = game.fetchTile(tileID: tileID) else {
            print("currentTile is nil")
            return
        }
        
        currentTile = fetchedTile
        titleLabel.text = currentTile!.title
        tileImageView.image = currentTile!.fetchImage()
        tileTextView.text = currentTile!.text
        
        if currentTile!.type == TileType.win.rawValue || currentTile!.type == TileType.lose.rawValue {
            tileButton1.isHidden = true
            tileButton2.isHidden = true
            endTileView.isHidden = false
            
            if currentTile!.type == TileType.win.rawValue {
                displayWinTile()
            }
            else {
                displayLoseTile()
            }
        }
        else {
            tileButton1.isHidden = false
            tileButton2.isHidden = false
            // Button names are option desc for button1, button 2
            options = currentTile!.fetchAllOptions()
            if (options?.count)! > 0 {
                tileButton1.setTitle(options?[0].desc, for: .normal)
            }
            if (options?.count)! > 1 {
                tileButton2.setTitle(options?[1].desc, for: .normal)
            }
            endTileView.isHidden = true
        }
    }
    
    func displayWinTile() {
        if let currentGame = game {
            loseButton.isHidden = true
            winButton.isHidden = false
            
            let winText = "Congratulations!\nYou just won \"\(currentGame.name!)\"."
            completeGameLabel.text = winText
        }
    }
    
    func displayLoseTile() {
        if let currentGame = game {
            loseButton.isHidden = false
            winButton.isHidden = true
            
            let loseText = "Oh no!\nYou just lost \"\(currentGame.name!)\"."
            completeGameLabel.text = loseText
        }
    }
    
    @IBAction func winButtonPressed(_ sender: Any) {
        
        if let navigationController = self.navigationController {
            // `PlayMode` is embedded in a navigation controller
            navigationController.popViewController(animated: true)
        }
    }
    
    @IBAction func loseButtonPressed(_ sender: Any) {
        if let rootTile = game?.root, let rootID = rootTile.id {
            displayTile(tileID: rootID)
        }
        else {
            return
        }
    }
    
    @IBAction func button1Pressed(_ sender: Any) {
        let option1 = options?[0]
        let newTile = option1?.child
        
        if let newTile = newTile, let newID = newTile.id {
            displayTile(tileID: newID)
        }
        else {
            return
        }
    }
    
    @IBAction func button2Pressed(_ sender: Any) {
        let option2 = options?[1]
        let newTile = option2?.child
        
        if let newTile = newTile, let newID = newTile.id {
            displayTile(tileID: newID)
        }
        else {
            return
        }
    }
}
