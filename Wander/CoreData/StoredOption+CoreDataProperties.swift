//
//  StoredOption+CoreDataProperties.swift
//  Wander
//
//  Created by Benjamin Gordon on 4/12/24.
//
//

import Foundation
import CoreData


extension StoredOption {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredOption> {
        return NSFetchRequest<StoredOption>(entityName: "StoredOption")
    }

    @NSManaged public var left: Bool
    @NSManaged public var desc: String?
    @NSManaged public var child: StoredTile?
    @NSManaged public var parent: StoredTile?

}

extension StoredOption : Identifiable {

}
