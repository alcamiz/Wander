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

    @NSManaged public var children: NSObject?
    @NSManaged public var id: UUID?
    @NSManaged public var options: NSObject?
    @NSManaged public var text: String?
    @NSManaged public var type: Int16
    @NSManaged public var game: StoredGame?

}

extension StoredTile : Identifiable {

}
