//
//  StoredOption+CoreDataProperties.swift
//  Wander
//
//  Created by Alex Cabrera on 3/6/24.
//
//

import Foundation
import CoreData


extension StoredOption {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredOption> {
        return NSFetchRequest<StoredOption>(entityName: "StoredOption")
    }

    @NSManaged public var text: String?
    @NSManaged public var parent: StoredTile?

}

extension StoredOption : Identifiable {

}
