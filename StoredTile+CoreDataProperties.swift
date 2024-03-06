//
//  StoredTile+CoreDataProperties.swift
//  Wander
//
//  Created by Benjamin Gordon on 3/4/24.
//
//

import Foundation
import CoreData


extension StoredTile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredTile> {
        return NSFetchRequest<StoredTile>(entityName: "StoredTile")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var type: Int16
    @NSManaged public var game: StoredGame?
    @NSManaged public var children: NSSet?

}

// MARK: Generated accessors for children
extension StoredTile {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: StoredOption)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: StoredOption)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

extension StoredTile : Identifiable {

}
