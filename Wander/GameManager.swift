//
//  GameManager.swift
//  Wander
//
//  Created by Benjamin Gordon on 3/7/24.
//

import Foundation
import CoreData

public class GameManager {
    var context:NSManagedObjectContext
//    var creator: StoredUser
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createGame(creator: StoredUser) -> StoredGame {
        
        return StoredGame(context: self.context, creator: creator)
    }
    
    func fetchGame(gameID:UUID) -> StoredGame? {
        
        do {
            let request = StoredGame.fetchRequest() as NSFetchRequest<StoredGame>
            let predicate = NSPredicate(format: "id == %@", gameID as CVarArg)
            request.predicate = predicate
            let res = try self.context.fetch(request)
            return res[0]
        }
        catch {
            return nil
        }
    }
    
    func fetchAllGames() -> [StoredGame]? {
        do {
            let res = try self.context.fetch(StoredGame.fetchRequest())
            return res
        }
        catch {
            return nil
        }
    }
}
