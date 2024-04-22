//
//  GameTitleViewController.swift
//  Wander
//
//  Created by Nihar Rao on 3/6/24.
//

import UIKit
import CropViewController
import FirebaseFirestore
import FirebaseStorage
private var db = Firestore.firestore()
private var storage = Storage.storage().reference()

class GameView: UIViewController, UINavigationControllerDelegate {
    
    var delegate: GameList!
    var game:StoredGame!
    var gameTitleTextField: UITextField!

    let defaultGameTitle = "Unnamed Game"
    var gameTitle: String!
    
    @IBOutlet weak var gameTitleLabel: UILabel!
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var playtestGameButton: UIButton!
    @IBOutlet weak var editGameButton: UIButton!
    @IBOutlet weak var publishGameButton: UIButton!
    @IBOutlet weak var deleteGameButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        gameTitleLabel.text = game.name
        
        gameImageView.backgroundColor = .secondarySystemBackground
        gameImageView.tintColor = .lightGray
        gameImageView.layer.cornerRadius = 12
        gameImageView.clipsToBounds = true

        if game.image == nil {
            gameImageView.image = UIImage(systemName: "questionmark")
        } else {
            gameImageView.image = game.fetchImage()
        }
        
        playtestGameButton.backgroundColor = Color.primary
        editGameButton.backgroundColor = Color.primary
        
        playtestGameButton.tintColor = .white
        editGameButton.tintColor = .white
        publishGameButton.tintColor = .white
        
        if game.published {
            publishGameButton.setTitle("Unpublish", for: .normal)
            publishGameButton.backgroundColor = Color.systemPink
            deleteGameButton.isHidden = true
        } else {
            publishGameButton.backgroundColor = Color.primary
        }
    }
    
    @IBAction func deleteGameButtonPressed(_ sender: Any) {
        if game.published {
            
        } else {
            let deleteAlertVC = UIAlertController(
                title: "Are you sure?",
                message: "If you delete the game \"\(self.game.name!)\", it cannot be undone.",
                preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                (alert) in
                self.delegate.deleteGame(game: self.game)
                self.navigationController?.popViewController(animated: true)
            })
            deleteAlertVC.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            deleteAlertVC.addAction(cancelAction)
            
            present(deleteAlertVC, animated: true)
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditGameSegue",
           let nextVC = segue.destination as? TileList {
            nextVC.game = game
        } else if segue.identifier == "PlaytestGameSegue",
                let nextVC = segue.destination as? PlaymodeViewController {
            
            nextVC.game = game
            if game.root != nil {
                nextVC.currentTile = game.root
            }
            else {
                print("no game root")
            }
        }
    }
    @IBAction func publishButtonPressed(_ sender: Any) {
        if game.published {
            publishGameButton.setTitle("Publish", for: .normal)
            publishGameButton.backgroundColor = Color.primary
            deleteGameButton.isHidden = false
            game.unpublish()
            
        } else {
            game.uploadToFirebase(db, storage)
            publishGameButton.backgroundColor = Color.systemPink
            publishGameButton.setTitle("Unpublish", for: .normal)
            deleteGameButton.isHidden = true
        }
        try! GlobalInfo.managedContext?.save()
    }
    
    @IBAction func editInfo(_ sender: Any) {
        let editForm = EditForm(nibName: "EditForm", bundle: nil)
        editForm.storedGame = game
        self.navigationController?.pushViewController(editForm, animated: true)
    }
}
