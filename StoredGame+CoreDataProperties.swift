//
//  StoredGame+CoreDataProperties.swift
//  Wander
//
//  Created by Benjamin Gordon on 3/6/24.
//
//

import Foundation
import CoreData


extension StoredGame {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredGame> {
        return NSFetchRequest<StoredGame>(entityName: "StoredGame")
    }

    @NSManaged public var creation: Date?
    @NSManaged public var descText: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var root: UUID?
    @NSManaged public var size: Int32
    @NSManaged public var tags: [String]?
    @NSManaged public var author: StoredUser?
    @NSManaged public var stages: NSSet?

}

// MARK: Generated accessors for stages
extension StoredGame {

    @objc(addStagesObject:)
    @NSManaged public func addToStages(_ value: StoredTile)

    @objc(removeStagesObject:)
    @NSManaged public func removeFromStages(_ value: StoredTile)

    @objc(addStages:)
    @NSManaged public func addToStages(_ values: NSSet)

    @objc(removeStages:)
    @NSManaged public func removeFromStages(_ values: NSSet)

}

extension StoredGame : Identifiable {

}
