//
//  InfoGame.swift
//  Wander
//
//  Created by Alex Cabrera on 4/8/24.
//

import Foundation
import UIKit



class InfoGame {
    
    var title: String
    var author: String
    var desc: String
    var tags: [String]
    var image: UIImage?
    var likes: UInt = 0
    var dislikes: UInt = 0
    var liked: LikeType = .neither
    var storedGame: StoredGame?
    var firebaseGame: FirebaseGame?
    
    init (storedGame: StoredGame) {
        self.title = storedGame.name ?? "Untitled"
        self.author = storedGame.author?.username ?? "Unknown"
        self.desc = storedGame.desc ?? "No description"
        self.tags = storedGame.tags ?? []
        /*
         Get likes and dislikes from Firebase.
         */
        if storedGame.image != nil {
            self.image = UIImage(data: storedGame.image!)
        } else {
            self.image = UIImage(systemName: "questionmark")
        }
        self.storedGame = storedGame
        self.liked = LikeType(rawValue: storedGame.liked)!

    }
    
    init (firebaseGame: FirebaseGame) {
        self.title = firebaseGame.name
        self.author = firebaseGame.authorUsername!
        self.desc = firebaseGame.desc
        self.tags = firebaseGame.tags
        self.likes = firebaseGame.likes
        self.dislikes = firebaseGame.dislikes
        if firebaseGame.image != nil {
            self.image = UIImage(data: firebaseGame.image!)
        } else {
            self.image = UIImage(systemName: "questionmark")
        }
        self.liked = LikeType(rawValue: firebaseGame.liked)!
        self.firebaseGame = firebaseGame
    }
    
    init () {
        self.title = "Empty"
        self.author = "No games"
        self.desc = ""
        self.tags = []
        self.image = UIImage(systemName: "questionmark")
    }
    
}
