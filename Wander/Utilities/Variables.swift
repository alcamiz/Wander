//
//  Variables.swift
//  Wander
//
//  Created by Alex Cabrera on 4/11/24.
//

import Foundation
import CoreData

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
    static var context: NSManagedObjectContext?
    static var currentUser: StoredUser?
}
