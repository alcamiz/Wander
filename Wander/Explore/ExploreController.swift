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



class ExploreController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var popularView: UICollectionView!
    @IBOutlet weak var newView: UICollectionView!
    @IBOutlet weak var historyView: UICollectionView!
    
    @IBOutlet weak var wanderButton: UIButton!
    @IBOutlet weak var wanderLabel: UILabel!
    
    // TODO: Change to FirebaseGame
    var popularGames: [FirebaseGame] = []
    var newGames: [FirebaseGame] = []
    var historyGames: [StoredGame] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    let debug = false
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if !debug {
            switch collectionView.accessibilityIdentifier {
                case "popularView":
                    return popularGames.count
                case "newView":
                    return newGames.count
                case "historyView":
                    return historyGames.count
                default:
                    return 0
            }
        }
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reUsable", for: indexPath) as! ExploreCell
        
        if !debug {
            var game: InfoGame
            switch collectionView.accessibilityIdentifier {
                    
                case "popularView":
                    game = InfoGame(firebaseGame: popularGames[indexPath.row])
                case "newView":
                    game = InfoGame(firebaseGame: newGames[indexPath.row])
                case "historyView":
                    game = InfoGame(storedGame: historyGames[indexPath.row])
                default:
                    return cell
            }

            cell.imageView.backgroundColor = .lightGray
            cell.titleLabel.text = game.title
            cell.imageView.image = game.image

        } else {
            cell.titleLabel.text = "Test"
            cell.imageView.backgroundColor = .lightGray
            cell.imageView.image = UIImage(systemName: "italic")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ExploreCell
        UIView.animateKeyframes(withDuration: 0.2, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/2) {
                cell.alpha = 0.6
                cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            }
            UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                cell.alpha = 1
                cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
        let storyboard = UIStoryboard(name: "GameScreen", bundle: nil)
        let gameScreen = storyboard.instantiateViewController(withIdentifier: "GameScreen") as! GameScreen
        
        if !debug {
            switch collectionView.accessibilityIdentifier {
                case "popularView":
                    gameScreen.infoGame = InfoGame(firebaseGame: popularGames[indexPath.row])
                case "newView":
                    gameScreen.infoGame = InfoGame(firebaseGame: newGames[indexPath.row])
                case "historyView":
                    gameScreen.infoGame = InfoGame(storedGame: historyGames[indexPath.row])
                default:
                    break
            }
        }
        self.navigationController?.pushViewController(gameScreen, animated: true)
    }
 
    func loadPopularPictures() {
        guard popularGames.count > 0 else {return}
        for i in 0...popularGames.count-1 {
            if let documentID = popularGames[i].id {
                let path = "gamePreviews/\(documentID).png"
                let reference = storage.child(path)
                reference.getData(maxSize: (64 * 1024 * 1024)) { (data, error) in
                    if let image = data {
                        print("image found for \(documentID)")
                        // let myImage: UIImage! = UIImage(data: image)
                        self.popularGames[i].image = image
                        self.popularView.reloadData()
                         // Use Image
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Explore"
        
        // TODO: Query game lists

        wanderButton.layer.cornerRadius = 8
        wanderButton.backgroundColor = UIColor(hex: "#0DCAD6")
        wanderButton.tintColor = .white
        wanderLabel.text = "Press the button to learn more about the app!"
        
        popularView.accessibilityIdentifier = "popularView"
        newView.accessibilityIdentifier = "newView"
        historyView.accessibilityIdentifier = "historyView"
        
        popularView.layer.cornerRadius = 12
        newView.layer.cornerRadius = 12
        historyView.layer.cornerRadius = 12

        popularView.register(UINib(nibName: "ExploreCell", bundle: nil), forCellWithReuseIdentifier: "reUsable")
        newView.register(UINib(nibName: "ExploreCell", bundle: nil), forCellWithReuseIdentifier: "reUsable")
        historyView.register(UINib(nibName: "ExploreCell", bundle: nil), forCellWithReuseIdentifier: "reUsable")
                    
        
        popularView.dataSource = self
        popularView.delegate = self
        popularView.backgroundColor = Color.primary
        
        Task {
            popularGames = await GameManager.queryGames(query: "", tag: "", sort: "")
            popularView.reloadData()
            loadPopularPictures()
        }
       
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = StoredGame.fetchRequest()
        let predicate = NSPredicate(format: "author == nil")
        fetchRequest.predicate = predicate
        let res = try! managedContext.fetch(fetchRequest)
        self.historyGames = res
        
       
        
        historyView.dataSource = self
        historyView.delegate = self
        historyView.backgroundColor = Color.primary
        
        newView.backgroundColor = Color.primary
    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
