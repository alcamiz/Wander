//
//  GameState.swift
//  Wander
//
//  Created by Alex Cabrera on 2/28/24.
//

import Foundation

public class Game {
    
    
    let id:UUID // PK

    // Info
    let creatorID:UUID // FK
    var name:String = ""
    var description:String = ""
    var tags:[String] = []
    
    var rootID:UUID? // FK
    var stageCount:UInt32 = 0
    
    var coreGame: StoredGame?
    
    init(creatorID:UUID) {
        self.id = UUID()
        self.creatorID = creatorID
    }
    
    func loadFromCore() {
        self.name = self.coreGame?.name ?? ""
        // load in image
        // get children 
    }
    
    init(storedVersion: StoredGame) {
        self.coreGame = storedVersion
        self.id = storedVersion.id!
        self.creatorID = (storedVersion.author?.id)!
        loadFromCore()
    }
    
    func saveToCore() -> Bool {
        guard coreGame != nil else {
            return false
        }
        
        return true 
        
    }
    
    func publish() -> Bool {
        return false 
    }
    
    /*init(gameID:UUID, creatorID:UUID, name:String, description:String, tags:[String], rootID:UUID, stageCount:UInt32) {
        self.gameID = gameID
        self.creatorID = creatorID
        self.name = name
        self.description = description
        self.tags = tags
        self.rootID = rootID
        self.stageCount = stageCount
    }*/
}
