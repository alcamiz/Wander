//
//  StoredGame+CoreDataProperties.swift
//  Wander
//
//  Created by Benjamin Gordon on 4/18/24.
//
//

import Foundation
import CoreData


extension StoredGame {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredGame> {
        return NSFetchRequest<StoredGame>(entityName: "StoredGame")
    }

    @NSManaged public var createCount: Int32
    @NSManaged public var createdOn: Date?
    @NSManaged public var desc: String?
    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var position: UUID?
    @NSManaged public var published: Bool
    @NSManaged public var publishedOn: Date?
    @NSManaged public var tags: [String]?
    @NSManaged public var liked: Int16
    @NSManaged public var author: StoredUser?
    @NSManaged public var root: StoredTile?
    @NSManaged public var tiles: NSSet?

}

// MARK: Generated accessors for tiles
extension StoredGame {

    @objc(addTilesObject:)
    @NSManaged public func addToTiles(_ value: StoredTile)

    @objc(removeTilesObject:)
    @NSManaged public func removeFromTiles(_ value: StoredTile)

    @objc(addTiles:)
    @NSManaged public func addToTiles(_ values: NSSet)

    @objc(removeTiles:)
    @NSManaged public func removeFromTiles(_ values: NSSet)

}

extension StoredGame : Identifiable {

}
