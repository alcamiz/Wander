//
//  StoredUser+CoreDataClass.swift
//  Wander
//
//  Created by Alex Cabrera on 3/6/24.
//
//

import Foundation
import CoreData


public class StoredUser: NSManagedObject {
    convenience init(context: NSManagedObjectContext, username: String) {
        self.init(context: context)
        self.id = UUID()
        self.username = username
        self.createCount = 0
        self.createdOn = Date()
    }
    
    func createGame(creator: StoredUser) -> StoredGame {
        let newGame = StoredGame(creator: creator)
        self.createCount += 1
        try! self.managedObjectContext?.save()
        return newGame
    }
    
    func fetchGame(gameID:UUID) -> StoredGame? {
        let predicate = NSPredicate(format: "id == %@", gameID as CVarArg)
        let res = self.createdGames?.filtered(using: predicate) as? Set<StoredGame>
        return res != nil && res!.isEmpty ? res!.first : nil
    }
    
    func fetchAllGames() -> [StoredGame]? {
        return (self.createdGames?.allObjects as? [StoredGame])?.sorted(by:{ $0.createdOn ?? Date.distantPast < $1.createdOn ?? Date.distantPast })
    }
    
    func deleteGame(game: StoredGame) -> Bool {
        guard game.author == self else {return false}
        self.managedObjectContext?.delete(game)
        try! self.managedObjectContext?.save()
        return true
    }
    
    func deleteAllGames() -> Bool {
        for game in self.createdGames! {
            self.managedObjectContext?.delete(game as! StoredGame)
        }
        try! self.managedObjectContext?.save()
        return true
    }
}
