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
    
    static func queryGames(domain: String?, query: String?, tag: String?, sort: String?) async -> [FirebaseGame] {
        let domainString: String = domain != nil ? domain! : "Title"
        var queriedGames: [FirebaseGame] = []
        var queryObj: Query? = db.collection("games").whereField("name", notIn: [""])
        if let queryString = query, queryString.count > 0 {
            var truncatedQuery = queryString.prefix(queryString.count - 1)
            let lastChar = (queryString.last?.unicodeScalars.first!.value)! + 1
            truncatedQuery.append(Character(UnicodeScalar(lastChar)!))
            
            if domainString == "Title" {
                queryObj = db.collection("games").whereField("name", isGreaterThanOrEqualTo: queryString)
                    .whereField("name", isLessThan: truncatedQuery)
            } else {
                var authors: [String] = []
                var authorQuery = db.collection("users").whereField("username", isGreaterThanOrEqualTo: queryString)
                    .whereField("username", isLessThan: truncatedQuery)
                let authorSnapshot = try? await authorQuery.getDocuments()
                if let authorList = authorSnapshot?.documents {
                    for author in authorList {
                        if let authorId = try? author.data(as: FirebaseUser.self).id {
                            authors.append(authorId)
                        }
                    }
                }
                queryObj = authors.count > 0 ? db.collection("games").whereField("author", in: authors) : nil
            }
        }
        guard var queryObject: Query = queryObj else {
            return []
        }
        if let tagString = tag, tagString.count > 0 {
            queryObject = queryObject.whereField("tags", arrayContains: tagString)
        }
        if let sortString = sort {
            if sortString == "Newest" {
                queryObject = queryObject.order(by: "publishedOn", descending: true).limit(to: 25)
            } else if sortString == "Oldest" {
                queryObject = queryObject.order(by: "publishedOn", descending: false).limit(to: 25)
            } else if sortString == "Least Popular" {
                queryObject = queryObject.order(by: "likes", descending: false).limit(to: 25)
            } else {
                queryObject = queryObject.order(by: "likes", descending: true).limit(to: 25)
            }
        }
        do {
            let querySnapshot = try await queryObject.getDocuments()
             
            for document in querySnapshot.documents {
                do {
                    let gameObj = try document.data(as: FirebaseGame.self)
                    let author = try await db.collection("users").document(gameObj.author).getDocument(as: FirebaseUser.self)
                    gameObj.authorUsername = author.username
                    queriedGames.append(gameObj)
                } catch let innerErr {
                    print("inner error \(innerErr)")
                }
            }
        } catch let outerErr {
            print("outer error \(outerErr)")
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
    
    static func nonDownloadedPublished(userID: String, alreadySaved: [String]) async -> [FirebaseGame] {
        var queriedGames: [FirebaseGame] = []
        var querySnapshot = db.collection("games")
            .whereField("author", isEqualTo: userID)
        
        let docList = try? await querySnapshot.getDocuments()
         
        for document in docList?.documents ?? [] {
            if let gameObj = try? document.data(as: FirebaseGame.self) {
                if !alreadySaved.contains(gameObj.id!) {
                    if let author = try? await db.collection("users").document(gameObj.author).getDocument(as: FirebaseUser.self) {
                        gameObj.authorUsername = author.username
                    }
                    queriedGames.append(gameObj)

                }
               
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
