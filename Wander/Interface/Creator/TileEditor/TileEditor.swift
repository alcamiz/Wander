//
//  TileEditor.swift
//  Wander
//
//  Created by Alex Cabrera on 4/17/24.
//

import UIKit
import CropViewController

class TileEditor: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, CropViewControllerDelegate  {
    
    // Updateable UI fields
    @IBOutlet weak var typeSelector: UISegmentedControl!
    @IBOutlet weak var titleEntry: UITextField!
    @IBOutlet weak var imageScene: UIImageView!
    @IBOutlet weak var textEntry: UITextView!
    @IBOutlet weak var titleEntryOne: UITextField!
    @IBOutlet weak var titleEntryTwo: UITextField!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // Static UI fields (for toggling visibility)
    @IBOutlet weak var branchLabelOne: UILabel!
    @IBOutlet weak var branchLabelTwo: UILabel!
    @IBOutlet weak var linkOutletOne: UIButton!
    @IBOutlet weak var linkOutletTwo: UIButton!
    @IBOutlet weak var newOutletOne: UIButton!
    @IBOutlet weak var newOutletTwo: UIButton!
    @IBOutlet weak var linkLabelOne: UILabel!
    @IBOutlet weak var linkLabelTwo: UILabel!
    @IBOutlet weak var newLabelOne: UILabel!
    @IBOutlet weak var newLabelTwo: UILabel!
    @IBOutlet weak var linkTextOne: UILabel!
    @IBOutlet weak var linkTextTwo: UILabel!
    @IBOutlet weak var staticLabelOne: UILabel!
    @IBOutlet weak var staticLabelTwo: UILabel!
    
    var exitButton: UIBarButtonItem?
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
        
        // Setup exit button
        if self.navigationController != nil {
            exitButton = UIBarButtonItem(title: "Exit")
            exitButton?.setTitleTextAttributes([.foregroundColor: UIColor.systemRed], for: .normal)
            exitButton?.target = self
            exitButton?.action = #selector(exitFunc)
            self.navigationItem.rightBarButtonItem = exitButton
        }
        
        // Hide tile types for root tiles
        if storedTile?.type == TileType.root.rawValue {
            typeSelector.isHidden = true
        }
        
        // Load stored/placeholder image
        if storedTile?.image != nil {
            imageScene.image = UIImage(data: storedTile!.image!)
            imageScene.contentMode = .scaleAspectFill
            imageButton.setTitle("Change Image", for: .normal)
        } else {
            imageScene.image = UIImage(systemName: "questionmark")
            imageScene.contentMode = .scaleAspectFit
            imageButton.setTitle("Add Image", for: .normal)
        }
        
        imageScene.backgroundColor = .systemGray5
        imageScene.layer.cornerRadius = 12
        imageScene.clipsToBounds = true
        imageScene.tintColor = .lightGray
        
        titleEntry.delegate = self
        textEntry.delegate = self
        titleEntryOne.delegate = self
        titleEntryTwo.delegate = self
        
        // Load information/placeholders to UI fields
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
            
            // Hide unecessary UI elements depending on tile type
            switch TileType(rawValue: storedTile!.type) {
                case .win:
                    toggleBranches(true)
                    typeSelector.selectedSegmentIndex = 1
                case .lose:
                    toggleBranches(true)
                    typeSelector.selectedSegmentIndex = 2
                default:
                    toggleBranches(false)
                    typeSelector.selectedSegmentIndex = 0
                    break
            }
            
            if storedTile?.leftTile != nil {
                self.linkTextOne.text = storedTile?.leftTile?.title
                self.linkTextOne.textColor = Color.primary
                linkedTiles.0 = storedTile?.leftTile
            }
            
            if storedTile?.rightTile != nil {
                self.linkTextTwo.text = storedTile?.rightTile?.title
                self.linkTextTwo.textColor = Color.primary
                linkedTiles.1 = storedTile?.rightTile
            }

        }
    }
    
    // Save to core data when back is pressed
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveInfo()
    }

    // Save all open tiles to core data, exit to tile list
    @objc
    func exitFunc() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers ;
        for aViewController in viewControllers {
            
            if aViewController is TileEditor {
                let iterEditor = aViewController as! TileEditor
                iterEditor.saveInfo()
            }
            
            if aViewController is TileList {
               self.navigationController!.popToViewController(aViewController, animated: false);
            }
        }
    }
    
    // Write to core data object, and save context
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
        }
        
        if titleEntryOne.text != nil && titleEntryOne.text!.count > 0 {
            storedTile?.leftButton = titleEntryOne.text
        } else {
            storedTile?.leftButton = nil
        }
        
        if linkedTiles.1 != nil {
            storedTile?.rightTile = linkedTiles.1
        }
        
        if titleEntryTwo.text != nil && titleEntryTwo.text!.count > 0 {
            storedTile?.rightButton = titleEntryTwo.text
        } else {
            storedTile?.rightButton = nil
        }
        
        if shouldCreateTile {
            createHandler?(storedTile)
        } else {
            updateHandler?(storedTile)
        }
        
        try? storedTile?.managedObjectContext?.save()
    }
    
    // MARK: - Children Tiles Handling
    
    // Open LinkView, link selected tile to left branch
    @IBAction func linkButtonOne(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LinkView", bundle: nil)
        let linkView = storyboard.instantiateViewController(withIdentifier: "LinkView") as! LinkView
        linkView.parentTile = storedTile
        
        linkView.selectAction = {tile in
            self.linkedTiles.0 = tile
            self.linkTextOne.text = tile?.title
            self.linkTextOne.textColor = Color.primary
        }
        self.navigationController?.pushViewController(linkView, animated: true)
    }
    
    // Open LinkView, link selected tile to right branch
    @IBAction func linkButtonTwo(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LinkView", bundle: nil)
        let linkView = storyboard.instantiateViewController(withIdentifier: "LinkView") as! LinkView
        linkView.parentTile = storedTile
        
        linkView.selectAction = {tile in
            self.linkedTiles.1 = tile
            self.linkTextTwo.text = tile?.title
            self.linkTextTwo.textColor = Color.primary
        }
        self.navigationController?.pushViewController(linkView, animated: true)
    }
    
    // Open new TileEditor, create new tile and link to left branch
    @IBAction func newButtonOne(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TileEditor", bundle: nil)
        let editorView = storyboard.instantiateViewController(withIdentifier: "TileEditor") as! TileEditor
        
        editorView.storedGame = storedTile?.game ?? storedGame
        editorView.createHandler = {tile in
            self.linkedTiles.0 = tile
            self.linkTextOne.text = tile?.title
            self.linkTextOne.textColor = Color.primary
        }
    
        self.navigationController?.pushViewController(editorView, animated: true)
    }
    
    // Open new TileEditor, create new tile and link to right branch
    @IBAction func newButtonTwo(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TileEditor", bundle: nil)
        let editorView = storyboard.instantiateViewController(withIdentifier: "TileEditor") as! TileEditor
        
        editorView.storedGame = storedTile?.game ?? storedGame
        editorView.createHandler = {tile in
            self.linkedTiles.1 = tile
            self.linkTextTwo.text = tile?.title
            self.linkTextTwo.textColor = Color.primary
        }
    
        self.navigationController?.pushViewController(editorView, animated: true)
    }
    
    // Open TileEditor to update currently linked left tile
    @IBAction func updateExistingOne(recognizer: UITapGestureRecognizer) {
        print("test")
        guard self.linkedTiles.0 != nil else {
            return
        }
        
        let storyboard = UIStoryboard(name: "TileEditor", bundle: nil)
        let editorView = storyboard.instantiateViewController(withIdentifier: "TileEditor") as! TileEditor
        
        editorView.storedTile = self.linkedTiles.0
        editorView.updateHandler = {tile in
            self.linkTextOne.text = tile?.title
            self.linkTextOne.textColor = Color.primary
        }
        
        self.navigationController?.pushViewController(editorView, animated: true)
    }
    
    // Open TileEditor to update currently linked right tile
    @IBAction func updateExistingTwo(recognizer: UITapGestureRecognizer) {
        guard self.linkedTiles.1 != nil else {
            return
        }
        
        let storyboard = UIStoryboard(name: "TileEditor", bundle: nil)
        let editorView = storyboard.instantiateViewController(withIdentifier: "TileEditor") as! TileEditor
        
        editorView.storedTile = self.linkedTiles.1
        editorView.updateHandler = {tile in
            self.linkTextTwo.text = tile?.title
            self.linkTextTwo.textColor = Color.primary
        }
        
        self.navigationController?.pushViewController(editorView, animated: true)
    }
    
    // MARK: - Tile Type Handling

    @IBAction func selectorUpdater(_ sender: Any) {
        
        switch typeSelector.selectedSegmentIndex {
            case 1:
                toggleBranches(true)
            case 2:
                toggleBranches(true)
            default:
                toggleBranches(false)
        }
    }
    
    // Show/hide UI fields based on tile type
    func toggleBranches(_ toggle: Bool) {
        branchLabelOne.isHidden = toggle
        titleEntryOne.isHidden = toggle
        linkOutletOne.isHidden = toggle
        newOutletOne.isHidden = toggle
        linkLabelOne.isHidden = toggle
        newLabelOne.isHidden = toggle
        linkTextOne.isHidden = toggle
        staticLabelOne.isHidden = toggle
        
        branchLabelTwo.isHidden = toggle
        titleEntryTwo.isHidden = toggle
        linkOutletTwo.isHidden = toggle
        newOutletTwo.isHidden = toggle
        linkLabelTwo.isHidden = toggle
        newLabelTwo.isHidden = toggle
        linkTextTwo.isHidden = toggle
        staticLabelTwo.isHidden = toggle
    }
    
    // MARK: - Image Handling
    
    @IBAction func imageAction(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated:true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        dismiss(animated: true)
        showCrop(image: info[.originalImage] as! UIImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    // Display CropViewController, called after image picker
    func showCrop(image: UIImage) {
        let cropVC = CropViewController(croppingStyle: .default, image: image)
        cropVC.toolbarPosition = .top
        
        // Aspect ratio
        cropVC.aspectRatioPreset = .presetCustom
        cropVC.customAspectRatio = CGSize(width: 6.0, height: 5.0)
        cropVC.aspectRatioLockEnabled = true
        
        // Done button
        cropVC.doneButtonTitle = "Done"
        cropVC.doneButtonColor = Color.primary
        
        // Cancel button
        cropVC.cancelButtonTitle = "Cancel"
        cropVC.cancelButtonColor = .systemRed
        
        cropVC.aspectRatioPickerButtonHidden = true
        cropVC.resetAspectRatioEnabled = false
     
        cropVC.delegate = self
        present(cropVC, animated: true)
    }
    
    // Dismiss CropViewController if "Cancel" tapped
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
    
    // Send back image from CropViewController when "Done" button tapped
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        shouldSaveImage = true
        imageScene.image = image
        imageScene.contentMode = .scaleAspectFill
        imageButton.setTitle("Change Image", for: .normal)

        cropViewController.dismiss(animated: true)

    }
    
    // MARK: - Keyboard Handling
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
