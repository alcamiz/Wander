//
//  ExploreController.swift
//  Wander
//
//  Created by Alex Cabrera on 3/25/24.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

private var db = Firestore.firestore()
private var storage = Storage.storage().reference()

class ExploreController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var popularView: UICollectionView!
    @IBOutlet weak var newView: UICollectionView!
    @IBOutlet weak var historyView: UICollectionView!
    
    @IBOutlet weak var wanderButton: UIButton!
    @IBOutlet weak var wanderLabel: UILabel!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    // TODO: Change to FirebaseGame
    var popularGames: [FirebaseGame] = []
    var newGames: [FirebaseGame] = []
    var historyGames: [StoredGame] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    let debug = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Explore"

        searchButton.tintColor = Color.primary
        
        popularView.delegate = self
        popularView.dataSource = self
        popularView.accessibilityIdentifier = "popularView"
        popularView.register(UINib(nibName: "ExploreCell", bundle: nil), forCellWithReuseIdentifier: "reUsable")
        
        newView.delegate = self
        newView.dataSource = self
        newView.accessibilityIdentifier = "newView"
        newView.register(UINib(nibName: "ExploreCell", bundle: nil), forCellWithReuseIdentifier: "reUsable")
        
        historyView.delegate = self
        historyView.dataSource = self
        historyView.accessibilityIdentifier = "historyView"
        historyView.register(UINib(nibName: "ExploreCell", bundle: nil), forCellWithReuseIdentifier: "reUsable")

        wanderButton.layer.cornerRadius = 8
        wanderButton.backgroundColor = UIColor(hex: "#0DCAD6")
        wanderButton.tintColor = .white
        wanderLabel.text = "Press the button to learn more about the app!"
        
        // Load popular/new games from Firebase
        Task {
            popularGames = await FirebaseHelper.queryGames(domain: "", query: "", tag: "", sort: "Most Popular")
            popularView.reloadData()
            FirebaseHelper.loadPictures(imageList: popularGames, basepath: "gamePreviews") { (index, data) in
                self.popularGames[index].image = data
                let indexPath = IndexPath(row: index, section: 0)
                self.popularView.reloadItems(at: [indexPath])
            }
            
            newGames = await FirebaseHelper.queryGames(domain: "", query: "", tag: "", sort: "Newest")
            newView.reloadData()
            FirebaseHelper.loadPictures(imageList: newGames, basepath: "gamePreviews") { (index, data) in
                self.newGames[index].image = data
                let indexPath = IndexPath(row: index, section: 0)
                self.newView.reloadItems(at: [indexPath])
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch previously played games from core data (recently played)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = StoredGame.fetchRequest()
        let predicate = NSPredicate(format: "author != %@", GlobalInfo.currentUser!)
        fetchRequest.predicate = predicate
        
        let res = try! managedContext.fetch(fetchRequest)
        self.historyGames = res

        historyView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if !debug {
            switch collectionView.accessibilityIdentifier {
                case "popularView":
                    guard popularGames.count > 0 else {
                        return 1
                    }
                    return popularGames.count
                case "newView":
                    guard newGames.count > 0 else {
                        return 1
                    }
                    return newGames.count
                case "historyView":
                    guard historyGames.count > 0 else {
                        return 1
                    }
                    return historyGames.count
                default:
                    return 0
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reUsable", for: indexPath) as! ExploreCell
        
        cell.imageView.contentMode = .scaleAspectFill

        if !debug {
        
            var game: InfoGame
            let emptyGame = InfoGame()
            
            switch collectionView.accessibilityIdentifier {
                    
                case "popularView":
                    if popularGames.count == 0 {
                        game = emptyGame
                    } else {
                        game = InfoGame(firebaseGame: popularGames[indexPath.row])
                    }
                case "newView":
                    if newGames.count == 0 {
                        game = emptyGame
                    } else {
                        game = InfoGame(firebaseGame: newGames[indexPath.row])
                    }
                case "historyView":
                    if historyGames.count == 0 {
                        game = emptyGame
                    } else {
                        game = InfoGame(storedGame: historyGames[indexPath.row])
                    }
                default:
                    return cell
            }
            
            if game.storedGame?.image == nil && game.firebaseGame?.image == nil {
                cell.imageView.contentMode = .scaleAspectFit
            }

            cell.imageView.image = game.image
            cell.imageView.backgroundColor = .secondarySystemBackground
            
            cell.titleLabel.text = game.title
            cell.titleLabel.adjustsFontSizeToFitWidth = false
            cell.titleLabel.lineBreakMode = .byTruncatingTail
            
            cell.authorLabel.text = game.author

        } else {
            cell.titleLabel.text = "Test"
            cell.imageView.backgroundColor = .secondarySystemBackground
            cell.imageView.image = UIImage(systemName: "questionmark")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ExploreCell
        
        Task {
            await UIView.animateKeyframes(withDuration: 0.1, delay: 0) {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/2) {
                    cell.alpha = 0.6
                }
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                    cell.alpha = 1
                }
            }
        }

        let storyboard = UIStoryboard(name: "GameScreen", bundle: nil)
        let gameScreen = storyboard.instantiateViewController(withIdentifier: "GameScreen") as! GameScreen
        
        if !debug {
            switch collectionView.accessibilityIdentifier {
                case "popularView":
                    guard popularGames.count > 0 else {
                        return
                    }
                    gameScreen.infoGame = InfoGame(firebaseGame: popularGames[indexPath.row])
                case "newView":
                    guard newGames.count > 0 else {
                        return
                    }
                    gameScreen.infoGame = InfoGame(firebaseGame: newGames[indexPath.row])
                case "historyView":
                    guard historyGames.count > 0 else {
                        return
                    }
                    gameScreen.infoGame = InfoGame(storedGame: historyGames[indexPath.row])
                default:
                    break
            }
        }
        self.navigationController?.pushViewController(gameScreen, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = collectionView.frame.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        return CGSize(width: 0.75 * height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 0)
    }
    
    @IBAction func wanderAction(_ sender: Any) {
        
        let controller = UIAlertController(
            title: "The True Meaning",
            message: "Wander is the friends we made along the way",
            preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Ok!", style: .default) {
            (action) in return
        })
        
        controller.addAction(UIAlertAction(title: "Ok?", style: .default) {
            (action) in return
        })
        
        present(controller,animated: true)
    }

}
