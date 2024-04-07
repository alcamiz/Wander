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
    
    func queryGames(query: String, tag: String, sort: String) -> [FirebaseGame] {
        var queriedGames: [FirebaseGame] = []
        var queryObj = db.collection("games").whereField("name", notIn: [""])
        if (query.count > 0) {
            var truncatedQuery = query.prefix(query.count - 1)
            let lastChar = (query.last?.unicodeScalars.first!.value)! + 1
            truncatedQuery.append(Character(UnicodeScalar(lastChar)!))
            print(truncatedQuery)
            queryObj = queryObj.whereField("name", isGreaterThanOrEqualTo: query)
                .whereField("name", isLessThan: truncatedQuery)
        }
       queryObj.getDocuments() {querySnapshot, err in
            guard err == nil else {
                return
            }
            for document in querySnapshot!.documents {
                do {
                    let gameObj = try document.data(as: FirebaseGame.self)
                    let path = "gamePreviews/\(document.documentID).png"
                    let reference = storage.child(path)
                    reference.getData(maxSize: (64 * 1024 * 1024)) { (data, error) in
                        if let image = data {
                            print("image found for \(document.documentID)")
                            // let myImage: UIImage! = UIImage(data: image)
                            gameObj.image = image
                            queriedGames.append(gameObj)
                             // Use Image
                        } else {
                            queriedGames.append(gameObj)
                        }
                        
                    }
                } catch {
                }
            }
        }
        return queriedGames
    }

}
