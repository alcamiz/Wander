//
//  Tile.swift
//  Wander
//
//  Created by Alex Cabrera on 2/28/24.
//

import Foundation

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

public class Tile {
    
    let id:UUID
    var text:String = ""
    var children:[TileOption] = []
    var type:TileType = .empty
    
    var coreTile:StoredTile?
    
    init(id:UUID) {
        self.id = id
        self.text = String()
        self.children = []
        self.type = TileType.empty
    }
    
    init(id:UUID, text:String, children:[TileOption], type:TileType) {
        self.id = id
        self.text = text
        self.children = children
        self.type = type
    }
    
    
    func loadFromCore() {
        // use self.coreTile here
        self.text = (self.coreTile?.text)!
        self.type = TileType(rawValue: (self.coreTile?.type)!)!
        self.children = []
        if let optionIDs = self.coreTile?.childIDs,
            let optionTexts = self.coreTile?.optionDescs  {
            for i in 0...optionIDs.count {
                children.append(TileOption(id: optionIDs[i], text: optionTexts[i]))
            }
        }
        
    }
    
    init(storedVersion: StoredTile) {
        self.coreTile = storedVersion
        self.id = storedVersion.id!
        loadFromCore()
        
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
            coreTile?.childIDs?.append(opt.id)
            coreTile?.optionDescs?.append(opt.text)
        }
        
        do {
            try context?.save()
        } catch {
            return false
        }
        return true
    }
}
