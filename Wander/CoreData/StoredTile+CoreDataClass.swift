//
//  StoredTile+CoreDataClass.swift
//  Wander
//
//  Created by Benjamin Gordon on 3/6/24.
//
//

import Foundation
import CoreData
import UIKit
import FirebaseFirestore
import FirebaseStorage


enum TileType:Int16 {
    case root
    case win
    case lose
    case between
    case empty
}

struct TileOption {
    var id:UUID
    var text:String
}

public class StoredTile: NSManagedObject {
    
    convenience init(game: StoredGame) {
        self.init(context: game.managedObjectContext!)
        self.id = UUID()
        self.game = game
        self.text = nil
        self.title = "Tile #\(game.createCount)"
        self.type = TileType.empty.rawValue
        self.createdOn = Date()
        self.leftButton = "Button 1"
        self.rightButton = "Button 2"
    }
    
    convenience init(game: StoredGame, webVersion: FirebaseTile) {
        self.init(context: game.managedObjectContext!)
        self.id = UUID(uuidString: webVersion.id!)
        self.game = game
        self.text = webVersion.text
        self.title = webVersion.title
        self.type = Int16(webVersion.type)
        self.createdOn = Date()
        if getType() != .win && getType() != .lose {
            self.leftButton = "Button 1"
            self.rightButton = "Button 2"
        }
    }
    
    func initializeOptions(webVersion: FirebaseTile) {
        guard webVersion.options.count == 2, webVersion.children.count == 2 else {return}
        self.leftTile = game?.fetchTile(tileID: UUID(uuidString: webVersion.children[0])!)
        self.leftButton = webVersion.options[0]
        self.rightTile = game?.fetchTile(tileID: UUID(uuidString: webVersion.children[1])!)
        self.rightButton =  webVersion.options[1]
    }
    
    func getType() -> TileType {
        return TileType(rawValue: self.type)!
    }
    
    func fetchAllChildren() -> [StoredTile?] {
        return [self.leftTile, self.rightTile]
    }
    
    func addImage(image: UIImage) {
        self.image = image.jpegData(compressionQuality: 0.75)
    }
    
    func fetchImage() -> UIImage? {
        return self.image != nil ? UIImage(data: self.image!) : nil
    }
    
    func downloadImage(callback: @escaping (Data?) -> Void) {
        let reference = GlobalInfo.storage.child("tilePics/\(id!.uuidString).jpeg")
        reference.getData(maxSize: (5 * 1024 * 1024)) { (data, error) in
            if error == nil && data != nil {
                self.image = data
                callback(data)
            }
        }
    }
    
    func uploadToFirebase(_ db: Firestore, _ storage: StorageReference) {
        let docString: String = self.id!.uuidString
        let imagePathRef = storage.child("tilePics/\(docString).jpeg")
        var data = [
            "title": self.title ?? "",
            "text": self.text ?? "",
            "type": self.type,
            "game": self.game?.id?.uuidString ?? "-1",
            "children": [],
            "options": []
        ] as [String : Any]
         
        if getType() != .win && getType() != .lose {
            data["children"] = [
                self.leftTile?.id?.uuidString ?? "",
                self.rightTile?.id?.uuidString ?? "",
            ]
            data["options"] = [self.leftButton ?? "", self.rightButton ?? ""]
        }
        
        // todo better use of async
        if let pic = self.image {
            let path = "tilePreviews/\(id!).jpeg"
            let _ = imagePathRef.putData(pic, metadata: nil)
        }
        db.collection("tiles").document(docString).setData(data)

    }
    
    func unpublish() {
        let documentID: String = id!.uuidString
        Task {
            try? await GlobalInfo.db.collection("tiles").document(documentID).delete()
            let imagePathRef = GlobalInfo.storage.child("tilePics/\(documentID).jpeg")
            try? await imagePathRef.delete()
        }
    }
    
}

