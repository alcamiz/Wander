//
//  Tile.swift
//  Wander
//
//  Created by Alex Cabrera on 2/28/24.
//

enum TileType:Int16 {
    case win
    case lose
    case between
    case empty
}

struct TileOption {
    var id:UInt64
    var text:String
    var coreOption:StoredOption?
}

public class Stage {
    
    let id:UInt64
    var text:String
    var children:[TileOption]
    var type:TileType
    
    var coreTile:StoredTile?
    
    init(id:UInt64) {
        self.id = id
        self.text = String()
        self.children = []
        self.type = TileType.empty
    }
    
    init(id:UInt64, text:String, children:[TileOption], type:TileType) {
        self.id = id
        self.text = text
        self.children = children
        self.type = type
    }
    
    func addCore(newCore: StoredTile) -> Bool {
        guard coreTile == nil else {
            return false
        }
        
        self.coreTile = newCore
        return true
    }
    
    func saveToCore() -> Bool {
        guard coreTile != nil else {
            return false
        }
        
        let context = coreTile?.managedObjectContext
        coreTile!.text = self.text
        coreTile?.type = self.type.rawValue
        
        for opt in self.children {
            guard opt.coreOption != nil else {
                return false
            }
            coreTile?.addToChildren(opt.coreOption!)
        }
        
        do {
            try context?.save()
        } catch {
            return false
        }
        return true
    }
}
