//
//  InfoGame.swift
//  Wander
//
//  Created by Alex Cabrera on 4/8/24.
//

import Foundation
import UIKit
import FirebaseFirestore



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
    var idString: String?
    
    func initializeLiked() async {
        let userID: String = GlobalInfo.currentUser!.id!
        let doc = GlobalInfo.db.collection("users").document(userID)
        let docFields = try? await doc.getDocument()
        let likeStruct = docFields!.get("liked") as! [String : Int]
        if let likedVal = likeStruct[idString!] {
            liked = LikeType(rawValue: Int16(likedVal))!
        } else {
            liked = .neither
        }
    }
    
    func updateUserLikes() async {
        let userID: String = GlobalInfo.currentUser!.id!
        let doc = GlobalInfo.db.collection("users").document(userID)
        let docFields = try! await doc.getDocument()
        var likeStruct = docFields.get("liked") as! [String : Int]
        likeStruct[idString!] = Int(liked.rawValue)
        try? await doc.updateData(["liked": likeStruct])
    }
    
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
        self.idString = storedGame.id?.uuidString
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
        
        //self.liked = LikeType.neither
        self.firebaseGame = firebaseGame
        self.idString = firebaseGame.id
    }
    
    init () {
        self.title = "Empty"
        self.author = "No games"
        self.desc = ""
        self.tags = []
        self.image = UIImage(systemName: "questionmark")
    }
    
    func like() async {
        await initializeLiked()
        guard self.liked != .like else {
            return
        }
        do {
            let doc = GlobalInfo.db.collection("games").document(self.idString ?? "m")
            try await doc.updateData(["likes": FieldValue.increment(Int64(1))])
            if self.liked == .dislike {
                try await doc.updateData(["dislikes": FieldValue.increment(Int64(-1))])
            }
            let cloudFields = try await doc.getDocument(as: FirebaseGame.self)
            self.likes = cloudFields.likes
            self.dislikes = cloudFields.dislikes
        } catch {}
        self.liked = .like
        await updateUserLikes()
    }
    
    func dislike() async {
        await initializeLiked()
        guard self.liked != .dislike else {
            return
        }
        do {
            let doc = GlobalInfo.db.collection("games").document(self.idString ?? "m")
            try await doc.updateData(["dislikes": FieldValue.increment(Int64(1))])
            if self.liked == .like {
                try await doc.updateData(["likes": FieldValue.increment(Int64(-1))])
            }
            let cloudFields = try await doc.getDocument(as: FirebaseGame.self)
            self.likes = cloudFields.likes
            self.dislikes = cloudFields.dislikes
        } catch {}
        self.liked = .dislike
        await updateUserLikes()
    }
    
}
