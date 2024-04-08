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
    }
    
    convenience init(game: StoredGame, webVersion: FirebaseTile) {
        self.init(context: game.managedObjectContext!)
        self.game = game
        self.text = webVersion.text
        self.title = webVersion.title
        self.type = Int16(webVersion.type)
        self.createdOn = Date()
    }
    
    func initializeOptions(webVersion: FirebaseTile) {
        guard webVersion.options.count > 0 else {return}
        for i in 0...webVersion.options.count-1 {
            let childTile = game?.fetchTile(tileID: UUID(uuidString: webVersion.children[i])!)
            createOption(tile: childTile, desc: webVersion.options[i])
        }
    }
    
    func getType() -> TileType {
        return TileType(rawValue: self.type)!
    }
    
    func createOption(tile: StoredTile?, desc: String) -> StoredOption {
        let opt = StoredOption(parent: self, child: tile, desc: desc)
        self.addToOptions(opt)
        return opt
    }
    
    func fetchOption(optionID : UUID) -> StoredOption? {
        let predicate = NSPredicate(format: "id == %@", optionID as CVarArg)
        let res = self.options?.filtered(using: predicate) as? Set<StoredOption>
        return res != nil && res!.isEmpty ? res!.first : nil
    }
    
    func fetchAllOptions() -> [StoredOption]? {
        return (self.options?.allObjects as? [StoredOption])?.sorted(by:{ $0.createdOn ?? Date.distantPast < $1.createdOn ?? Date.distantPast })
    }
    
    func fetchAllChildren() -> [StoredTile?] {
        let options = fetchAllOptions() ?? []
        return options.map { $0.child }
    }
    
    func deleteOption(option: StoredOption) -> Bool {
        guard option.parent == self else {return false}
        self.managedObjectContext?.delete(option)
        try! self.managedObjectContext?.save()
        return true
    }
    
    func deleteAllOptions() -> Bool {
        for option in self.options! {
            self.managedObjectContext?.delete(option as! StoredOption)
        }
        try! self.managedObjectContext?.save()
        return true
    }
    
    func addImage(image: UIImage) {
        self.image = image.pngData()
    }
    
    func fetchImage() -> UIImage? {
        return self.image != nil ? UIImage(data: self.image!) : nil
    }
    
    func uploadToFirebase(_ db: Firestore, _ storage: StorageReference) {
        let docString: String = self.id!.uuidString
        let imagePathRef = storage.child("tilePics/\(docString).png")
        var data = [
            "title": self.title ?? "",
            "text": self.text ?? "",
            "type": self.type,
            "game": self.game?.id?.uuidString ?? "-1",
        ] as [String : Any]
        
        if let childOptions = fetchAllOptions() {
            let childIDs = childOptions.compactMap {$0.child?.id?.uuidString}
            let buttonTexts = childOptions.compactMap {$0.desc}
            data["children"] = childIDs
            data["options"] = buttonTexts
        }
        
        if let dateObj = self.createdOn {
            data["createdOn"] = dateObj
        }
        
        // todo better use of async
        if let pic = self.image {
            let _ = imagePathRef.putData(pic, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    return
                }
                imagePathRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        return
                    }
                    let picURL = downloadURL.absoluteString
                    data["image"] = picURL
                    db.collection("tiles").document(docString).setData(data)
                }
            }
        } else {
            db.collection("tiles").document(docString).setData(data)
        }
    }
    
}

