//
//  GameScreen.swift
//  Wander
//
//  Created by Alex Cabrera on 4/4/24.
//

import UIKit
import CoreData


class GameScreen: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var imageScreen: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var tagView: UICollectionView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tagHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var game: FirebaseGame?
    var storedGame: StoredGame?
    var tags: [String]?
    var tagID: String = UUID().uuidString
    
    let debug = false
    let copyPasta = "I'd just like to interject for a moment. What you're refering to as Linux, is in fact, GNU/Linux, or as I've recently taken to calling it, GNU plus Linux. Linux is not an operating system unto itself, but rather another free component of a fully functioning GNU system made useful by the GNU corelibs, shell utilities and vital system components comprising a full OS as defined by POSIX.\nMany computer users run a modified version of the GNU system every day, without realizing it. Through a peculiar turn of events, the version of GNU which is widely used today is often called Linux, and many of its users are not aware that it is basically the GNU system, developed by the GNU Project.\nThere really is a Linux, and these people are using it, but it is just a part of the system they use. Linux is the kernel: the program in the system that allocates the machine's resources to the other programs that you run. The kernel is an essential part of an operating system, but useless by itself; it can only function in the context of a complete operating system. Linux is normally used in combination with the GNU operating system: the whole system is basically GNU with Linux added, or GNU/Linux. All the so-called Linux distributions are really distributions of GNU/Linux!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tagView.register(UINib(nibName: "ContractionCell", bundle: nil), forCellWithReuseIdentifier: self.tagID)
        self.imageScreen.backgroundColor = .lightGray
        self.descriptionLabel.textColor = .gray
        
        if !debug {
            titleLabel.text = game?.name
            authorLabel.text = game?.author
            
            if game?.image == nil {
                imageScreen.image = UIImage(systemName: "italic")
            } else {
                imageScreen.image = UIImage(data: game!.image!)
            }
            
            if game!.tags.count == 0 {
                tagHeight.constant = 0
            } else {
                tags = game!.tags
            }

            descriptionLabel.text = "\(game?.desc ?? "None")"

        } else {
            titleLabel.text = "Empty"
            authorLabel.text = "User"
            imageScreen.image = UIImage(systemName: "italic")
            descriptionLabel.text = "\(copyPasta)"
        }

        tagView.delegate = self
        tagView.dataSource = self
        playButton.tintColor = UIColor(rgb: 0x191970)
    }
    
    @IBAction func playAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Playmode", bundle: nil)
        let playMode = storyboard.instantiateViewController(withIdentifier: "PlaymodeViewController") as! PlaymodeViewController
        
        // TODO: Download game
        Task {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            var storedGame = await self.game?.download(managedContext: managedContext)
            playMode.game = storedGame
            if let rootTile = storedGame!.root {
                playMode.currentTile = rootTile
            } else {
                let alert = UIAlertController(title: "Invalid Root tile", message: String(storedGame!.tiles!.count), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            self.navigationController?.pushViewController(playMode, animated: true)
        }
      
    }
    
    @IBAction func showDescription(_ sender: UITapGestureRecognizer) {
        
        let controller = UIAlertController(
            title: "Description",
            message: "\n\(descriptionLabel!.text!)",
            preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Ok", style: .default))
        present(controller,animated: true)
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (!debug) {
            if tags == nil {
                return 0
            } else {
                return tags!.count
            }
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.tagID, for: indexPath) as! ContractionCell
        
        if game != nil {
            if tags != nil {
                cell.mainLabel.text = tags![indexPath.row]
            }
        } else {
            switch indexPath.row % 4 {
                case 0:
                    cell.mainLabel.text = "Horror"
                case 1:
                    cell.mainLabel.text = "Gaming"
                case 2:
                    cell.mainLabel.text = "Sci-Fi"
                case 3:
                    cell.mainLabel.text = "Drama"
                default:
                    cell.mainLabel.text = "Nil"
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = self.view.frame.width
        let availableHeight = tagHeight.constant
        
        let cellWidth = availableWidth / 3.5
        let cellHeight = availableHeight
        
        return CGSize(width: cellWidth, height: cellHeight)
    }

}
