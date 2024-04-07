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
    
    static func queryGames() {
        db.collection("games").getDocuments(){
            querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents{
                    do {
                        let gameObj = try document.data(as: FirebaseGame.self)
                        print("we did it yay")
                    } catch {
                        print("meow")
                    }
                    print(document.data()["name"]!)
                    let path = "gamePreviews/\(document.documentID).png"
                    let reference = storage.child(path)
                    reference.getData(maxSize: (64 * 1024 * 1024)) { (data, error) in
                        if let _ = error {
                            print("no image found for \(document.documentID)")
                        } else {
                            if let image = data {
                                print("image found for \(document.documentID)")
                                // let myImage: UIImage! = UIImage(data: image)
                                
                                 // Use Image
                            }
                        }
                    }

                }
                
            }
        }
    }
}
