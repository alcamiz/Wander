//
//  StoredGame+CoreDataClass.swift
//  Wander
//
//  Created by Benjamin Gordon on 3/6/24.
//
//

import Foundation
import CoreData
import UIKit
import FirebaseFirestore
import FirebaseStorage


public class StoredGame: NSManagedObject {
    convenience init(creator: StoredUser) {
        self.init(context: creator.managedObjectContext!)
        self.id = UUID()
        self.author = creator
        self.name = "Game #\(creator.createdGames?.count ?? 0)"
        self.tags = []
        self.desc = nil
        self.createCount = 0
        self.createdOn = Date()
        self.published = false
        self.root = createTile()
        self.root?.type = TileType.root.rawValue
    }
    
    convenience init(webVersion: FirebaseGame, managedContext: NSManagedObjectContext) {
        self.init(context: managedContext)
        //self.author = webVersion.author (change model!)
        self.published = true
        self.author = StoredUser(webVersion: FirebaseUser(id: webVersion.author, username: webVersion.authorUsername!), managedContext: managedContext)
        //self.root = something (fetch the tiles)
        self.id = UUID(uuidString: webVersion.id!)
        self.name = webVersion.name
        self.createCount = Int32(webVersion.createCount)
        self.publishedOn = webVersion.publishedOn
        self.image = webVersion.image
        self.desc = webVersion.desc
        self.tags = webVersion.tags
    }
    
    func createTile() -> StoredTile {
        let newTile = StoredTile(game: self)
        self.createCount += 1
        try! self.managedObjectContext?.save()
        return newTile
    }
    
    func fetchTile(tileID: UUID) -> StoredTile? {
        let predicate = NSPredicate(format: "id == %@", tileID as CVarArg)
        let res = self.tiles?.filtered(using: predicate) as? Set<StoredTile>
        return res != nil && !res!.isEmpty ? res!.first : nil
    }
    
    func fetchAllTiles() -> [StoredTile]? {
        return (self.tiles?.allObjects as? [StoredTile])?.sorted(by:{ $0.createdOn ?? Date.distantPast < $1.createdOn ?? Date.distantPast })
    }

    func deleteTile(tile: StoredTile) -> Bool {
        guard tile.game == self else {return false}
        self.managedObjectContext?.delete(tile)
        try! self.managedObjectContext?.save()
        return true
    }
    
    func deleteAllTile() -> Bool {
        for tile in self.tiles! {
            self.managedObjectContext?.delete(tile as! StoredTile)
        }
        try! self.managedObjectContext?.save()
        return true
    }
    
    func addImage(image: UIImage) {
        self.image = image.jpegData(compressionQuality: 0.75)
    }

    func fetchImage() -> UIImage? {
        return self.image != nil ? UIImage(data: self.image!) : nil
    }

    func uploadToFirebase(_ db: Firestore, _ storage: StorageReference) {
        let docString: String = self.id!.uuidString
        let tiles = fetchAllTiles() ?? []
        var tileIDs = tiles.map { ($0.id ?? UUID()).uuidString }
        let publishDate = Date()
        
        var data = [
            "name": self.name ?? "",
            "desc": self.desc ?? "",
            "tags": self.tags ?? [],
            "createCount": self.createCount,
            "publishedOn": publishDate,
            "author": self.author?.id ?? "",
            "tiles": tileIDs,
            "root": self.root?.id?.uuidString ?? "-1",
        ] as [String : Any]
        // todo better use of async
        if let pic = self.image {
            let imagePathRef = storage.child("gamePreviews/\(docString).jpeg")
            let _ = imagePathRef.putData(pic, metadata: nil)
        }
        
        db.collection("games").document(docString).setData(data)

        tiles.forEach { $0.uploadToFirebase(db, storage) }
        self.published = true
        self.publishedOn = publishDate
    }
    
    func unpublish() {
        let documentID: String = id!.uuidString
        Task {
            try? await GlobalInfo.db.collection("games").document(documentID).delete()
            let imagePathRef = GlobalInfo.storage.child("gamePreviews/\(documentID).jpeg")
            try? await imagePathRef.delete()
        }
        let tiles = fetchAllTiles() ?? []
        tiles.forEach { $0.unpublish() }
        self.published = false
    }
}




