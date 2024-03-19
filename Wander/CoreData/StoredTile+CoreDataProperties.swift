//
//  StoredTile+CoreDataProperties.swift
//  Wander
//
//  Created by Alex Cabrera on 3/15/24.
//
//

import Foundation
import CoreData


extension StoredTile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredTile> {
        return NSFetchRequest<StoredTile>(entityName: "StoredTile")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var type: Int16
    @NSManaged public var createdOn: Date?
    @NSManaged public var options: NSSet?
    @NSManaged public var game: StoredGame?

}

// MARK: Generated accessors for options
extension StoredTile {

    @objc(addOptionsObject:)
    @NSManaged public func addToOptions(_ value: StoredOption)

    @objc(removeOptionsObject:)
    @NSManaged public func removeFromOptions(_ value: StoredOption)

    @objc(addOptions:)
    @NSManaged public func addToOptions(_ values: NSSet)

    @objc(removeOptions:)
    @NSManaged public func removeFromOptions(_ values: NSSet)

}

extension StoredTile : Identifiable {

}
