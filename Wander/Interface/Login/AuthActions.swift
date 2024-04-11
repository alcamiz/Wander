//
//  AuthActions.swift
//  Wander
//
//  Created by Benjamin Gordon on 4/6/24.
//

import Foundation
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

func storeAfterSignIn(managedContext: NSManagedObjectContext, userInfo: User, username: String) -> StoredUser {
    return StoredUser(context: managedContext, username: username, id: userInfo.uid)
}

/*func getUser(managedContext: NSManagedObjectContext) -> StoredUser? {
    let res = try? managedContext.fetch(StoredUser.fetchRequest())
    return res != nil && res!.count > 0 ? res![0] : nil
    
}*/
