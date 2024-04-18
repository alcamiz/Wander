//
//  GameManager.swift
//  Wander
//
//  Created by Benjamin Gordon on 3/7/24.
//

import Foundation
import CoreData
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

private var db = Firestore.firestore()
private var storage = Storage.storage().reference()

public class GameManager {
    var context:NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchGame(gameID:UUID) -> StoredGame? {
        let request = StoredGame.fetchRequest() as NSFetchRequest<StoredGame>
        let predicate = NSPredicate(format: "id == %@", gameID as CVarArg)
        request.predicate = predicate
        
        let res = try? self.context.fetch(request)
        return res != nil && res!.count > 0 ? res![0] : nil
    }
    
    func fetchAllGames() -> [StoredGame]? {
        return try? self.context.fetch(StoredGame.fetchRequest())
    }

}
