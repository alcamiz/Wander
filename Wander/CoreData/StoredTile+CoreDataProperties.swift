//
//  StoredTile+CoreDataProperties.swift
//  Wander
//
//  Created by Benjamin Gordon on 4/12/24.
//
//

import Foundation
import CoreData


extension StoredTile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredTile> {
        return NSFetchRequest<StoredTile>(entityName: "StoredTile")
    }

    @NSManaged public var createdOn: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var type: Int16
    @NSManaged public var leftButton: String?
    @NSManaged public var rightButton: String?
    @NSManaged public var game: StoredGame?
    @NSManaged public var leftTile: StoredTile?
    @NSManaged public var rightTile: StoredTile?

}

extension StoredTile : Identifiable {

}
