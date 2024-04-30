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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameImageView.backgroundColor = .secondarySystemBackground
        gameImageView.tintColor = .lightGray
        gameImageView.layer.cornerRadius = 12
        gameImageView.clipsToBounds = true
        
        playtestGameButton.layer.cornerRadius = 10
        playtestGameButton.clipsToBounds = true
        playtestGameButton.backgroundColor = .systemGray5
        playtestGameButton.tintColor = Color.primary
        
        editGameButton.layer.cornerRadius = 10
        editGameButton.clipsToBounds = true
        editGameButton.backgroundColor = .systemGray5
        editGameButton.tintColor = Color.primary
        
        publishGameButton.layer.cornerRadius = 10
        publishGameButton.clipsToBounds = true
        
        if game.published {
            publishGameButton.setTitle("Unpublish", for: .normal)
            publishGameButton.backgroundColor = Color.systemPink
            publishGameButton.tintColor = .white
        } else {
            publishGameButton.backgroundColor = .systemGray5
            publishGameButton.tintColor = Color.primary
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameTitleLabel.text = game.name
        
        if game.image == nil {
            gameImageView.image = UIImage(systemName: "questionmark")
            gameImageView.contentMode = .scaleAspectFit
        } else {
            gameImageView.image = game.fetchImage()
            gameImageView.contentMode = .scaleAspectFill
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
            publishGameButton.backgroundColor = .systemGray5
            publishGameButton.tintColor = Color.primary
            game.unpublish()
            
        } else {
            game.uploadToFirebase(db, storage)
            publishGameButton.backgroundColor = Color.systemPink
            publishGameButton.tintColor = .white
            publishGameButton.setTitle("Unpublish", for: .normal)
        }
        try? GlobalInfo.managedContext?.save()
    }
    
    @IBAction func editInfo(_ sender: Any) {
        let editForm = GameEditor(nibName: "GameEditor", bundle: nil)
        editForm.storedGame = game
        self.navigationController?.pushViewController(editForm, animated: true)
    }
}
