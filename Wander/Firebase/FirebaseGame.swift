//
//  FirebaseGame.swift
//  Wander
//
//  Created by Benjamin Gordon on 4/5/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import CoreData

private var db = Firestore.firestore()
private var storage = Storage.storage().reference()

public class FirebaseGame: Codable, ImageableFirebase {
    @DocumentID var id: String?
    var author: String
    var authorUsername: String?
    var root: String
    var createCount: Int
    var publishedOn: Date?
    var name: String
    var desc: String
    var tiles: [String]
    var tags: [String]
    var image: Data?
    var likes: UInt
    var dislikes: UInt
    
    func downloadTiles(_ storedGame: StoredGame) async {
        // first pass: initialize objects
        var firebaseTiles: [FirebaseTile] = []
        var storedTiles: [StoredTile] = []
        for tileID in tiles {
            do {
                let tileDoc = try await db.collection("tiles").document(tileID).getDocument()
                let tileObj = try tileDoc.data(as: FirebaseTile.self)
                firebaseTiles.append(tileObj)
                storedTiles.append(StoredTile(game: storedGame, webVersion: tileObj))
            } catch {
            }
        }
        guard storedTiles.count > 0 else {return}
        
        // second pass: link tiles together, download images
        for i in 0...storedTiles.count-1 {
            storedTiles[i].initializeOptions(webVersion: firebaseTiles[i])
        }
        try? storedGame.managedObjectContext!.save()
        
        var downloadCount = 0
        for i in 0...storedTiles.count - 1 {
            storedTiles[i].downloadImage() { (data) in
                storedTiles[i].image = data
                downloadCount += 1
                if (downloadCount == storedTiles.count) {
                    try? storedGame.managedObjectContext!.save()
                }
            }
        }
    
    }
    
    func download(managedContext: NSManagedObjectContext) async -> StoredGame {
        let game = StoredGame(webVersion: self, managedContext: managedContext)
        await downloadTiles(game)
        game.root = game.fetchTile(tileID: UUID(uuidString: self.root)!)
        try? managedContext.save()
        return game
    }
    
}
