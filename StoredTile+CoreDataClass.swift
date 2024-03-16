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

struct TileOption {
    var id:UUID
    var text:String
}

public class StoredTile: NSManagedObject {
    
    convenience init(game: StoredGame) {
        self.init(context: game.managedObjectContext!)
        self.id = UUID()
        self.game = game
        self.text = ""
        self.title = "Tile #\(game.createCount)"
        self.type = TileType.empty.rawValue
        self.createdOn = Date()
    }
    
    func getType() -> TileType {
        return TileType(rawValue: self.type)!
    }
    
    func createOption(parent: StoredTile, child: StoredTile, desc: String) -> StoredOption {
        let opt = StoredOption(parent: parent, child: child, desc: desc)
        self.addToOptions(opt)
        return opt
    }
    
    func fetchOption(optionID : UUID) -> StoredOption? {
        let predicate = NSPredicate(format: "id == %@", optionID as CVarArg)
        let res = self.options?.filtered(using: predicate) as? Set<StoredOption>
        return res != nil && res!.isEmpty ? res!.first : nil
    }
    
    func fetchAllOptions() -> [StoredOption]? {
        return (self.options?.allObjects as? [StoredOption])?.sorted(by:{ $0.createdOn ?? Date.distantPast < $1.createdOn ?? Date.distantPast })
    }
    
    func deleteOption(option: StoredOption) -> Bool {
        guard option.parent == self else {return false}
        self.managedObjectContext?.delete(option)
        try! self.managedObjectContext?.save()
        return true
    }
    
    func addImage(image: UIImage) {
        self.image = image.pngData()
    }
}
