//
//  Variables.swift
//  Wander
//
//  Created by Alex Cabrera on 4/11/24.
//

import Foundation
import CoreData
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

struct DebugInfo {
    static let global = false
    static let login = false
    static let explore = false
    static let search = false
    static let gameScreen = false
    static let creator = false
    static let playmode = false
    static let profile = false
}

struct GlobalInfo {
    static var managedContext: NSManagedObjectContext?
    static var currentUser: StoredUser?
    static var tagList = ["Horror", "Adventure", "Drama", "Romance", "Sports", "Sci-Fi", "Fantasy", "Historical", "Mystery", "Historical", "Educational", "Indie"]
    static var domainList = ["Title", "Author"]
    static var sortList = ["Ascending", "Descending"]
    static var db = Firestore.firestore()
    static var storage = Storage.storage().reference()
}


