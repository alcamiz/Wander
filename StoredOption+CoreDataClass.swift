//
//  StoredOption+CoreDataClass.swift
//  Wander
//
//  Created by Alex Cabrera on 3/15/24.
//
//

import Foundation
import CoreData

@objc(StoredOption)
public class StoredOption: NSManagedObject {
    convenience init(parent: StoredTile, child: StoredTile, desc: String) {
        self.init(context: parent.managedObjectContext!)
        self.parent = parent
        self.child = child
        self.desc = desc
        self.createdOn = Date()
    }
}
