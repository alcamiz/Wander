//
//  Stage.swift
//  Wander
//
//  Created by Alex Cabrera on 2/28/24.
//

enum StageType {
    case win
    case lose
    case between
    case empty
}

struct StageOption {
    var stageId:UInt64
    var description:String
}

class Stage {
    
    var stageId:UInt64
    var stageText:String
    var children:[StageOption]
    var type:StageType
    
    init(stageId:UInt64) {
        self.stageId = stageId
        self.stageText = String()
        self.children = []
        self.type = StageType.empty
    }
    
    init(stageId:UInt64, stageText:String, children:[StageOption], type:StageType) {
        self.stageId = stageId
        self.stageText = stageText
        self.children = children
        self.type = type
    }
}
