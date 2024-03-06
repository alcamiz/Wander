//
//  GameState.swift
//  Wander
//
//  Created by Alex Cabrera on 2/28/24.
//

public class Game {
    
    
    var gameID:UInt64 // PK

    // Info
    var creatorID:UInt64 // FK
    var name:String
    var description:String
    var tags:[String]
    
    var rootID:UInt64? // FK
    var stageCount:UInt32
    
    init(gameID:UInt64, creatorID:UInt64, name:String) {
        self.gameID = gameID
        self.creatorID = creatorID
        self.name = name
        self.description = String()
        self.tags = []
        self.stageCount = 0
    }
    
    init(gameID:UInt64, creatorID:UInt64, name:String, description:String, tags:[String], rootID:UInt64, stageCount:UInt32) {
        self.gameID = gameID
        self.creatorID = creatorID
        self.name = name
        self.description = description
        self.tags = tags
        self.rootID = rootID
        self.stageCount = stageCount
    }
}
