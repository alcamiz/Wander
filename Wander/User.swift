//
//  User.swift
//  Wander
//
//  Created by Alex Cabrera on 3/6/24.
//

public class User {
    var id:Int64
    var username:String
    var createdGames:[Game]
    
    init(id: Int64, username: String) {
        self.id = id
        self.username = username
        self.createdGames = []
    }
    
    init(id: Int64, username: String, createdGames: [Game]) {
        self.id = id
        self.username = username
        self.createdGames = createdGames
    }
    
    
}
