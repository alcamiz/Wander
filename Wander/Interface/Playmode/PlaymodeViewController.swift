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
        
        if game != nil {
            currentTile = game?.root
        }
        
        // Create a custom back button
        let exitGameButton = UIBarButtonItem(title: "Exit Game", style: .plain, target: nil, action: nil)
        exitGameButton.tintColor = .red
        
        // Set the custom back button for the previous view controller
        navigationController?.navigationBar.topItem?.backBarButtonItem = exitGameButton

        if (currentTile != nil) {
            displayTile(tile: currentTile)
        }
        
        // Set up endTileView
        endTileView.backgroundColor = Color.secondary
        completeGameLabel.textColor = .white
        winButton.setTitleColor(Color.secondary, for: .normal)
        loseButton.setTitleColor(Color.secondary, for: .normal)
        winButton.setTitle("Exit Game", for: .normal)
        loseButton.setTitle("Try Again", for: .normal)
    }
    
    // Displays contents of tile
    func displayTile(tile: StoredTile?) {
        if game == nil {
            print("game is nil")
            return
        }
        
        if tile == nil {
            print("currentTile is nil")
            return
        }
        
        // Set tile's title
        currentTile = tile
        titleLabel.text = currentTile!.title
        
        // Display tile's image, if any
        tileImageView.image = currentTile!.fetchImage()
        
        // Display tile's text and make the TextView uneditable by user/player
        tileTextView.text = currentTile!.text
        tileTextView.isEditable = false
        
        // If the current tile is an end tile, display accordingly
        if currentTile!.type == TileType.win.rawValue || currentTile!.type == TileType.lose.rawValue {
            // Hide button options (linked to other tiles)
            tileButton1.isHidden = true
            tileButton2.isHidden = true
            // Display end tile view
            endTileView.isHidden = false
            
            if currentTile!.type == TileType.win.rawValue {
                // Current tile is a win tile, set up win messages
                displayWinTile()
            }
            else {
                // Current tile is a lose tile, set up lose messages
                displayLoseTile()
            }
        }
        else {
            // Current tile links to other tiles, display linking buttons
            tileButton1.isHidden = false
            tileButton2.isHidden = false
            
            // Button names are option desc for button1, button 2
            tileButton1.setTitle(currentTile!.leftButton, for: .normal)
            tileButton2.setTitle(currentTile!.rightButton, for: .normal)
            endTileView.isHidden = true
        }
    }
    
    // Set up win tile
    func displayWinTile() {
        if let currentGame = game {
            loseButton.isHidden = true
            winButton.isHidden = false
            
            let winText = "Congratulations!\nYou just won \"\(currentGame.name!)\"."
            completeGameLabel.text = winText
        }
    }
    
    // Set up lose tile
    func displayLoseTile() {
        if let currentGame = game {
            loseButton.isHidden = false
            winButton.isHidden = true
            
            let loseText = "Oh no!\nYou just lost \"\(currentGame.name!)\"."
            completeGameLabel.text = loseText
        }
    }
    
    // On win end tile. When button pressed, exit playmode screen
    @IBAction func winButtonPressed(_ sender: Any) {
        if let navigationController = self.navigationController {
            // `PlayMode` is embedded in a navigation controller
            navigationController.popViewController(animated: true)
        }
    }
    
    // On lose tile. When button pressed, redirect to beginning of game/root tile
    @IBAction func loseButtonPressed(_ sender: Any) {
        if let rootTile = game?.root {
            displayTile(tile: rootTile)
        }
        else {
            return
        }
    }
    
    // On in-between tile. When button pressed, redirect to tile associated with first child
    @IBAction func button1Pressed(_ sender: Any) {
        guard let displayedTile = currentTile else {
            return
        }
        guard let leftTile = displayedTile.leftTile else {
            return
        }
        displayTile(tile: leftTile)
    }
    
    // On in-between tile. When button pressed, redirect to tile associated with second child
    @IBAction func button2Pressed(_ sender: Any) {
        guard let displayedTile = currentTile else {
            return
        }
        guard let rightTile = displayedTile.rightTile else {
            return
        }
        displayTile(tile: rightTile)
    }
}
