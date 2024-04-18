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
import FirebaseStorage

private var db = Firestore.firestore()
private var storage = Storage.storage().reference()


func storeAfterSignup(managedContext: NSManagedObjectContext, userInfo: User, username: String) -> StoredUser {
    let newUser = StoredUser(context: managedContext, username: username, id: userInfo.uid)
    try! managedContext.save()
    return newUser
}

func storeAfterLogin(managedContext: NSManagedObjectContext, userInfo: User) async {
    // see if user already exists
    let fetchRequest = StoredUser.fetchRequest()
    let predicate = NSPredicate(format: "id == %@", userInfo.uid)
    fetchRequest.predicate = predicate
    if let res = try? managedContext.fetch(fetchRequest), res.count > 0 {
        GlobalInfo.currentUser = res[0]
    } else { // pull info from Firebase
        do {
            let user = try await db.collection("users").document(userInfo.uid).getDocument(as: FirebaseUser.self)
            GlobalInfo.currentUser = StoredUser(webVersion: user, managedContext: managedContext)
            try managedContext.save()
        } catch {}
    }
}

/*func getUser(managedContext: NSManagedObjectContext) -> StoredUser? {
    let res = try? managedContext.fetch(StoredUser.fetchRequest())
    return res != nil && res!.count > 0 ? res![0] : nil
    
}*/
