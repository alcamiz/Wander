//
//  StoredTile+CoreDataClass.swift
//  Wander
//
//  Created by Benjamin Gordon on 3/6/24.
//
//

import Foundation
import CoreData
import UIKit

enum TileType:Int16 {
    case win
    case lose
    case between
    case empty
}

public class StoredTile: NSManagedObject {
    convenience init(context: NSManagedObjectContext?, game: StoredGame) {
        self.init(entity: NSEntityDescription.entity(forEntityName: "StoredTile", in: context!)!, insertInto: context)
        self.id = UUID()
        self.game = game
        self.text = ""
        self.type = TileType.empty.rawValue
        self.childIDs = []
        self.optionDescs = []
    }
    
    func fetchChild(childID: UUID) -> StoredTile? {
        do {
            let request = StoredTile.fetchRequest() as NSFetchRequest<StoredTile>
            let predicate = NSPredicate(format: "id == %@", childID as CVarArg)
            request.predicate = predicate
            let res = try self.managedObjectContext?.fetch(request)
            return res![0]
            
        }
        catch {
            return nil
        }
    }
    
    func addOption(childID: UUID, childDesc: String) {
        childIDs?.append(childID)
        optionDescs?.append(childDesc)
    }
    
    func addImage(image: UIImage) {
        self.image = image.pngData()
    }
}
