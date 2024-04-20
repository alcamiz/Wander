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
    
    var infoGame: InfoGame?
//    var tags: [String]?
    var tagID: String = UUID().uuidString
    
    let debug = false
    let copyPasta = "I'd just like to interject for a moment. What you're refering to as Linux, is in fact, GNU/Linux, or as I've recently taken to calling it, GNU plus Linux. Linux is not an operating system unto itself, but rather another free component of a fully functioning GNU system made useful by the GNU corelibs, shell utilities and vital system components comprising a full OS as defined by POSIX.\nMany computer users run a modified version of the GNU system every day, without realizing it. Through a peculiar turn of events, the version of GNU which is widely used today is often called Linux, and many of its users are not aware that it is basically the GNU system, developed by the GNU Project.\nThere really is a Linux, and these people are using it, but it is just a part of the system they use. Linux is the kernel: the program in the system that allocates the machine's resources to the other programs that you run. The kernel is an essential part of an operating system, but useless by itself; it can only function in the context of a complete operating system. Linux is normally used in combination with the GNU operating system: the whole system is basically GNU with Linux added, or GNU/Linux. All the so-called Linux distributions are really distributions of GNU/Linux!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tagView.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: self.tagID)
        self.imageScreen.backgroundColor = .lightGray
        self.descriptionLabel.textColor = .gray
        
        imageScreen.layer.cornerRadius = 12
        imageScreen.clipsToBounds = true
        imageScreen.tintColor = .black
        
        authorLabel.textColor = Color.primary
        
        if !debug {
            titleLabel.text = infoGame!.title
            authorLabel.text = infoGame!.author
            imageScreen.image = infoGame!.image

            if infoGame!.tags.count == 0 {
                tagHeight.constant = 0
            }

            descriptionLabel.text = infoGame!.desc

        } else {
            titleLabel.text = "Empty"
            authorLabel.text = "User"
            imageScreen.image = UIImage(systemName: "italic")
            descriptionLabel.text = "\(copyPasta)"
        }

        tagView.delegate = self
        tagView.dataSource = self
        playButton.tintColor = Color.primary
        playButton.titleLabel?.textColor = Color.primary
    }
    
    @IBAction func playAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Playmode", bundle: nil)
        let playMode = storyboard.instantiateViewController(withIdentifier: "PlaymodeViewController") as! PlaymodeViewController
        
        if !debug {
            if infoGame!.storedGame != nil {
                playMode.game = infoGame!.storedGame
                if let rootTile = playMode.game!.root {
                    playMode.currentTile = rootTile
                }
                self.navigationController?.pushViewController(playMode, animated: true)
                
            } else if infoGame!.firebaseGame != nil {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let managedContext = appDelegate.persistentContainer.viewContext
                let fetchRequest = StoredGame.fetchRequest()
                let predicate = NSPredicate(format: "id == %@", infoGame!.firebaseGame!.id! as CVarArg)
                fetchRequest.predicate = predicate
                let res = try! managedContext.fetch(fetchRequest)
                if res.count > 0 {
                    print(res[0])
                    playMode.game = res[0]
                    if let rootTile = playMode.game!.root {
                        playMode.currentTile = rootTile
                    }
                    self.navigationController?.pushViewController(playMode, animated: true)
                } else {
                    Task {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let managedContext = appDelegate.persistentContainer.viewContext
                        let storedGame = await self.infoGame?.firebaseGame!.download(managedContext: managedContext)
                        infoGame?.storedGame = storedGame
                        playMode.game = storedGame
                        if let rootTile = storedGame!.root {
                            playMode.currentTile = rootTile
                        }
                        self.navigationController?.pushViewController(playMode, animated: true)
                    }
                }
            }
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
            return infoGame!.tags.count
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.tagID, for: indexPath) as! TagCell
        
        if !debug {
            cell.labelView.text = infoGame!.tags[indexPath.row]
        } else {
            switch indexPath.row % 4 {
                case 0:
                    cell.labelView.text = "Horror"
                case 1:
                    cell.labelView.text = "Gaming"
                case 2:
                    cell.labelView.text = "Sci-Fi"
                case 3:
                    cell.labelView.text = "Drama"
                default:
                    cell.labelView.text = "Nil"
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
