//
//  FirebaseGame.swift
//  Wander
//
//  Created by Benjamin Gordon on 4/5/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

public class FirebaseGame: Codable {
    @DocumentID var id: String?
    var author: String
    var root: String
    var createCount: Int
    var createdOn: Date?
    var name: String
    var desc: String
    var tiles: [String]
    var tags: [String]
    var image: Data?
    
    func downloadTiles() {
        
    }
    
}
