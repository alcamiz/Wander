//
//  FirebaseTile.swift
//  Wander
//
//  Created by Benjamin Gordon on 4/15/24.
//

import Foundation

import FirebaseFirestore

public class FirebaseTile: Codable, ImageableFirebase {
    @DocumentID var id: String?
    var image: Data?
    var text: String
    var title: String
    var type: Int
    var game: String
    var children: [String]
    var options: [String]
}
