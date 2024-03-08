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
    convenience init(context: NSManagedObjectContext?, creator: StoredUser) {
        self.init(entity: NSEntityDescription.entity(forEntityName: "StoredGame", in: context!)!, insertInto: context)
        self.id = UUID()
        self.author = creator
        //let existingGames = creator.createdGames?.count ?? 0
        self.name = "Untitled"
        self.size = 0
        self.tags = []
        self.descText = ""
    }
    
    func addTile() -> StoredTile {
        // call constructor
        let newTile = StoredTile(context: self.managedObjectContext, game: self)
        if self.size == 0 {
            self.root = newTile.id
        }
        self.size += 1
        return newTile
    }
    
    func getTiles() -> [StoredTile] {
        return self.tiles?.allObjects as! [StoredTile]
    }
    
    func deleteTile(tile: StoredTile) -> Bool {
        
        guard tile.game == self else {
            return false
        }
        
        guard self.managedObjectContext != nil else {
            return false
        }
        
        self.managedObjectContext?.delete(tile)
        self.size -= 1
        return true
    }
    
    func publish() {
        self.creation = Date()
    }
    
    func addImage(image: UIImage) {
        self.image = image.pngData()
    }

}
