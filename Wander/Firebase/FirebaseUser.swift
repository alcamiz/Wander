//
//  FirebaseUser.swift
//  Wander
//
//  Created by Benjamin Gordon on 4/15/24.
//

import Foundation
import FirebaseFirestore

public class FirebaseUser: Codable, ImageableFirebase {
    @DocumentID var id: String?
    var email: String?
    var username: String
    var image: Data?
    
    init(id: String, username: String) {
        self.id = id
        self.username = username
    }
}
