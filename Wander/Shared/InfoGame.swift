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
    
    var inStore: Bool
    var inFirebase: Bool
    
    var storedGame: StoredGame?
    var firebaseGame: FirebaseGame?
    
    init (storedGame: StoredGame) {
        self.title = storedGame.name ?? "Untitled"
        self.author = storedGame.author?.username ?? "Unknown"
        self.desc = storedGame.desc ?? "No description"
        self.tags = storedGame.tags ?? []
        
        if storedGame.image != nil {
            self.image = UIImage(data: storedGame.image!)
        } else {
            self.image = UIImage(systemName: "italic")
        }
        
        self.inStore = true
        self.inFirebase = false // TODO: Might change for final release
        self.storedGame = storedGame

    }
    
    init (firebaseGame: FirebaseGame) {
        self.title = firebaseGame.name
        self.author = firebaseGame.authorUsername!
        self.desc = firebaseGame.desc
        self.tags = firebaseGame.tags
        
        if firebaseGame.image != nil {
            self.image = UIImage(data: firebaseGame.image!)
        } else {
            self.image = UIImage(systemName: "italic")
        }
        
        self.inFirebase = true
        self.inStore = false // TODO: Might change for final
        self.firebaseGame = firebaseGame
    }
    
}
