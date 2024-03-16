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


public class StoredGame: NSManagedObject {
    convenience init(creator: StoredUser) {
        self.init(context: creator.managedObjectContext!)
        self.id = UUID()
        self.author = creator
        self.name = "Game #\(creator.createCount)"
        self.tags = []
        self.desc = ""
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
    
    func addImage(image: UIImage) {
        self.image = image.pngData()
    }

}
