//
//  FirebaseHelper.swift
//  Wander
//
//  Created by Alex Cabrera on 4/11/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

private var db = Firestore.firestore()
private var storage = Storage.storage().reference()

class FirebaseHelper {
    
    static func queryGames(query: String?, tag: String?, sort: String?) async -> [FirebaseGame] {
        var queriedGames: [FirebaseGame] = []
        var queryObj = db.collection("games").whereField("name", notIn: [""])
        if let queryString = query, queryString.count > 0 {
            var truncatedQuery = queryString.prefix(queryString.count - 1)
            let lastChar = (queryString.last?.unicodeScalars.first!.value)! + 1
            truncatedQuery.append(Character(UnicodeScalar(lastChar)!))
            queryObj = queryObj.whereField("name", isGreaterThanOrEqualTo: queryString)
                .whereField("name", isLessThan: truncatedQuery)
        }
        if let tagString = tag, tagString.count > 0 {
            queryObj = queryObj.whereField("tags", arrayContains: tagString)
        }
        do {
            let querySnapshot = try await queryObj.getDocuments()
             
            for document in querySnapshot.documents {
                do {
                    let gameObj = try document.data(as: FirebaseGame.self)
                    let author = try await db.collection("users").document(gameObj.author).getDocument(as: FirebaseUser.self)
                    gameObj.authorUsername = author.username
                    queriedGames.append(gameObj)
                } catch {
                    print("inner error")
                }
            }
        } catch {
            print("outer error")
        }
        
        return queriedGames
    }
    
    static func loadPictures(imageList: [ImageableFirebase], basepath: String, callback: @escaping (Int, Data?) -> Void) {
        guard imageList.count > 0 else {return}
        for i in 0...imageList.count-1 {
            if let documentID = imageList[i].id {
                let path = "\(basepath)/\(documentID).jpeg"
                let reference = storage.child(path)
                reference.getData(maxSize: (5 * 1024 * 1024)) { (data, error) in
                    callback(i, data)
                }
            }
        }
    }
    
    static func gamesByAuthor(userID: String) async -> [FirebaseGame] {
        var queriedGames: [FirebaseGame] = []
        let querySnapshot = try? await db.collection("games").whereField("author", isEqualTo: userID).getDocuments()
         
        for document in querySnapshot?.documents ?? [] {
            do {
                let gameObj = try document.data(as: FirebaseGame.self)
                let author = try await db.collection("users").document(gameObj.author).getDocument(as: FirebaseUser.self)
                gameObj.authorUsername = author.username
                queriedGames.append(gameObj)
            } catch {
            }
        }
        return queriedGames
    }
    
    static func usernameAlreadyExists(username: String) async -> Bool {
        let querySnapshot = try? await db.collection("users").whereField("username", isEqualTo: username).getDocuments()
        if let snapshot = querySnapshot, snapshot.count > 0 {
            return true
        }
        return false
    }
    
    
}
