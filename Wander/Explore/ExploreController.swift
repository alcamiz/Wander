//
//  ExploreController.swift
//  Wander
//
//  Created by Alex Cabrera on 3/25/24.
//

import UIKit

// Code from a kid named StackOverflow
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
    self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

class ExploreController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var popularView: UICollectionView!
    @IBOutlet weak var newView: UICollectionView!
    
    @IBOutlet weak var wanderButton: UIButton!
    @IBOutlet weak var wanderLabel: UILabel!
    
    // TODO: Change to FirebaseGame
    let popularGames: [StoredGame] = []
    let newGames: [StoredGame] = []
    let debug = true
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        if !debug {
            switch collectionView.accessibilityIdentifier {
                case "popularView":
                    return popularGames.count
                case "newView":
                    return newGames.count
                default:
                    return 0
            }
        }
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reUsable", for: indexPath) as! ExploreCell
        
        // TODO: Change to FirebaseGame
        if !debug {
            var game: StoredGame
            switch collectionView.accessibilityIdentifier {
                case "popularView":
                    game = popularGames[indexPath.row]
                case "newView":
                    game = newGames[indexPath.row]
                default:
                    return cell
            }
            
            cell.titleLabel.text = game.name
            cell.imageView.backgroundColor = .lightGray
            cell.imageView.image = if game.image != nil {
                UIImage(data: game.image!)
            } else {
                UIImage(systemName: "italic")
            }
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
            var tArray: [StoredGame] // TODO: Change to FirebaseGame
            switch collectionView.accessibilityIdentifier {
                case "popularView":
                    tArray = popularGames
                case "newView":
                    tArray = newGames
                default:
                    tArray = []
            }
            gameScreen.game = tArray[indexPath.row]
        }
        self.navigationController?.pushViewController(gameScreen, animated: true)
    }
    
    let searchController = UISearchController(searchResultsController: nil)
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Explore"

        wanderButton.layer.cornerRadius = 8
        wanderButton.backgroundColor = UIColor(rgb: 0x0DCAD6)
        wanderButton.tintColor = .white
        wanderLabel.text = "Press the button to learn more about the app!"
        
        popularView.accessibilityIdentifier = "popularView"
        newView.accessibilityIdentifier = "newView"
        
        popularView.layer.cornerRadius = 12
        newView.layer.cornerRadius = 12

        popularView.register(UINib(nibName: "ExploreCell", bundle: nil), forCellWithReuseIdentifier: "reUsable")
        newView.register(UINib(nibName: "ExploreCell", bundle: nil), forCellWithReuseIdentifier: "reUsable")
                
        popularView.dataSource = self
        popularView.delegate = self
        popularView.backgroundColor = Color.primary
        
        newView.dataSource = self
        newView.delegate = self
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
