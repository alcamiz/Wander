//
//  NewEditor.swift
//  Wander
//
//  Created by Alex Cabrera on 4/17/24.
//

import UIKit

class NewEditor: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var typeSelector: UISegmentedControl!
    @IBOutlet weak var titleEntry: UITextField!
    @IBOutlet weak var imageScene: UIImageView!
    @IBOutlet weak var textEntry: UITextView!
    @IBOutlet weak var titleEntryOne: UITextField!
    @IBOutlet weak var titleEntryTwo: UITextField!
    @IBOutlet weak var imageButton: UIButton!
    
    var saveButton: UIBarButtonItem?
    var storedGame: StoredGame?
    var storedTile: StoredTile?
    var shouldSaveImage = false
    var shouldCreateTile = false
    
    var updateHandler: ((StoredTile?) -> Void)?
    var createHandler: ((StoredTile?) -> Void)?
    
    var linkedTiles: (StoredTile?, StoredTile?)
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        if self.navigationController != nil {
            saveButton = UIBarButtonItem(title: "Save")
            saveButton?.target = self
            saveButton?.action = #selector(saveInfo)

            self.navigationItem.rightBarButtonItem = saveButton
            self.navigationItem.leftBarButtonItem?.title = "Cancel"
        }
        
        if storedTile?.type == TileType.root.rawValue {
            typeSelector.isHidden = true
        }
        
        if storedTile?.image != nil {
            imageScene.image = UIImage(data: storedTile!.image!)
            imageScene.contentMode = .scaleAspectFill
            imageButton.setTitle("Change Image", for: .normal)
        } else {
            imageScene.image = UIImage(systemName: "questionmark")
            imageScene.contentMode = .scaleAspectFit
            imageButton.setTitle("Add Image", for: .normal)
        }
        
        imageScene.layer.backgroundColor = UIColor.lightGray.cgColor
        imageScene.layer.cornerRadius = 12
        imageScene.clipsToBounds = true
        imageScene.tintColor = .black
        
        if storedTile != nil {
            if storedTile!.title != nil && storedTile!.title!.count > 0 {
                titleEntry.text = storedTile!.title!
            } else {
                titleEntry.text = "Unknown"
            }
            
            if storedTile!.text != nil && storedTile!.text!.count > 0 {
                textEntry.text = storedTile!.text!
            }
            
            if storedTile!.leftButton != nil && storedTile!.leftButton!.count > 0 {
                titleEntryOne.text = storedTile!.leftButton!
            }
            
            if storedTile!.rightButton != nil && storedTile!.rightButton!.count > 0 {
                titleEntryTwo.text = storedTile!.rightButton!
            }
            
            switch TileType(rawValue: storedTile!.type) {
                case .win:
                    typeSelector.selectedSegmentIndex = 1
                case .lose:
                    typeSelector.selectedSegmentIndex = 2
                default:
                    break
            }
            
            linkedTiles.0 = storedTile!.leftTile
            linkedTiles.1 = storedTile!.rightTile

        }
    }
    
    @objc
    func saveInfo() {
        
        if storedTile == nil {
            guard storedGame != nil else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            storedTile = storedGame?.createTile()
            shouldCreateTile = true
        }
        
        if titleEntry.text != nil && titleEntry.text!.count != 0 {
            storedTile?.title = titleEntry!.text
        } else {
            storedTile?.title = "Untitled"
        }
        storedTile?.text = textEntry.text
        
        if shouldSaveImage {
            storedTile?.image = imageScene.image?.jpegData(compressionQuality: 1.0)
        }
        
        let text = typeSelector.titleForSegment(at: typeSelector.selectedSegmentIndex)
        switch text {
            case "Default":
                storedTile?.type = TileType.between.rawValue
            case "Win":
                storedTile?.type = TileType.win.rawValue
            case "Lose":
                storedTile?.type = TileType.lose.rawValue
            default:
                break
        }
        
        if linkedTiles.0 != nil {
            storedTile?.leftTile = linkedTiles.0
            if titleEntryOne.text != nil && titleEntryOne.text!.count > 0 {
                storedTile?.leftButton = titleEntryOne.text
            } else {
                storedTile?.leftButton = "Left Option"
            }
        }
        
        if linkedTiles.1 != nil {
            storedTile?.rightTile = linkedTiles.1
            if titleEntryTwo.text != nil && titleEntryTwo.text!.count > 0 {
                storedTile?.rightButton = titleEntryTwo.text
            } else {
                storedTile?.rightButton = "Right Option"
            }
        }
        
        if shouldCreateTile {
            createHandler?(storedTile)
        } else {
            updateHandler?(storedTile)
        }
        
        try! storedTile?.managedObjectContext?.save()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func linkButtonOne(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LinkView", bundle: nil)
        let linkView = storyboard.instantiateViewController(withIdentifier: "LinkView") as! LinkView
        linkView.parentTile = storedTile
        
        linkView.selectAction = {tile in
            self.linkedTiles.0 = tile
        }
        self.navigationController?.pushViewController(linkView, animated: true)
    }
    
    @IBAction func linkButtonTwo(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LinkView", bundle: nil)
        let linkView = storyboard.instantiateViewController(withIdentifier: "LinkView") as! LinkView
        linkView.parentTile = storedTile
        
        linkView.selectAction = {tile in
            self.linkedTiles.1 = tile
        }
        self.navigationController?.pushViewController(linkView, animated: true)
    }
    
    @IBAction func imageAction(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated:true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        shouldSaveImage = true
        imageScene.image = info[.originalImage] as? UIImage
        imageScene.contentMode = .scaleAspectFill
        imageButton.setTitle("Change Image", for: .normal)
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

}
