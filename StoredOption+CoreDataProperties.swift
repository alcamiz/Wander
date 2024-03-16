//
//  StoredOption+CoreDataProperties.swift
//  Wander
//
//  Created by Alex Cabrera on 3/15/24.
//
//

import Foundation
import CoreData


extension StoredOption {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredOption> {
        return NSFetchRequest<StoredOption>(entityName: "StoredOption")
    }

    @NSManaged public var desc: String?
    @NSManaged public var createdOn: Date?
    @NSManaged public var parent: StoredTile?
    @NSManaged public var child: StoredTile?

}

extension StoredOption : Identifiable {

}
