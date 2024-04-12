//
//  StoredUser+CoreDataProperties.swift
//  Wander
//
//  Created by Benjamin Gordon on 4/12/24.
//
//

import Foundation
import CoreData


extension StoredUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredUser> {
        return NSFetchRequest<StoredUser>(entityName: "StoredUser")
    }

    @NSManaged public var createdOn: Date?
    @NSManaged public var id: String?
    @NSManaged public var picture: Data?
    @NSManaged public var username: String?
    @NSManaged public var createdGames: NSSet?

}

// MARK: Generated accessors for createdGames
extension StoredUser {

    @objc(addCreatedGamesObject:)
    @NSManaged public func addToCreatedGames(_ value: StoredGame)

    @objc(removeCreatedGamesObject:)
    @NSManaged public func removeFromCreatedGames(_ value: StoredGame)

    @objc(addCreatedGames:)
    @NSManaged public func addToCreatedGames(_ values: NSSet)

    @objc(removeCreatedGames:)
    @NSManaged public func removeFromCreatedGames(_ values: NSSet)

}

extension StoredUser : Identifiable {

}
