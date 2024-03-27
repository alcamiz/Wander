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
        self.name = "Game #\(creator.createCount)"
        self.tags = []
        self.desc = nil
        self.createCount = 0
        self.createdOn = Date()
    }
    
    func createTile() -> StoredTile {
        let newTile = StoredTile(game: self)
        self.root = tiles?.count == 0 ? newTile : nil
        self.createCount += 1
        try! self.managedObjectContext?.save()
        return newTile
    }
    
    func fetchTile(tileID: UUID) -> StoredTile? {
        let predicate = NSPredicate(format: "id == %@", tileID as CVarArg)
        let res = self.tiles?.filtered(using: predicate) as? Set<StoredTile>
        return res != nil && res!.isEmpty ? res!.first : nil
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
        self.image = image.pngData()
    }

    func fetchImage() -> UIImage? {
        return self.image != nil ? UIImage(data: self.image!) : nil
    }
    
    func uploadToFirebase(_ db: Firestore, _ storage: StorageReference) -> String {
        let docString: String = self.id!.uuidString
        let tiles = fetchAllTiles() ?? []
        var tileIDs = tiles.map { ($0.id ?? UUID()).uuidString }
        let imagePathRef = storage.child("gamePreviews/\(docString).png")
        
        var data = [
            "name": self.name ?? "",
            "desc": self.desc ?? "",
            "image": "",
            "tags": self.tags ?? [],
            "createdOn": self.createdOn ?? Date(),
            "createCount": self.createCount,
            "author": self.author?.id?.uuidString ?? "",
            "tiles": tileIDs,
            "root": self.root?.id?.uuidString ?? "-1",
        ] as [String : Any]
        
        // todo better use of async
        if let pic = self.image {
            let _ = imagePathRef.putData(pic, metadata: nil) { (metadata, error) in
              guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
              }
              // You can also access to download URL after upload.
                imagePathRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  // Uh-oh, an error occurred!
                  return
                }
                let picURL = downloadURL.absoluteString
                data["image"] = picURL
                db.collection("games").document(docString).setData(data)
              }
            }
        } else {
            db.collection("games").document(docString).setData(data)
        }
        // todo upload pictures
        
        return "Success"
    }
}
