//
//  GameEditor.swift
//  Wander
//
//  Created by Alex Cabrera on 4/14/24.
//

import UIKit

class GameEditor: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, ModifyGameTagsDelegate {
    
    @IBOutlet weak var imageScene: UIImageView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var titleEntry: UITextField!
    @IBOutlet weak var descriptionEntry: UITextView!
    @IBOutlet weak var tagDisplay: UICollectionView!
    @IBOutlet weak var tagButton: UIButton!
    
    let picker = UIImagePickerController()
    var storedGame: StoredGame?
    var saveButton: UIBarButtonItem?
    var shouldSaveImage = false
    let cellId = UUID().uuidString
    var tags: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        imageButton.setTitleColor(.white, for: .normal)
        imageButton.layer.backgroundColor = Color.primary.cgColor
        imageButton.layer.cornerRadius = 12
        imageButton.clipsToBounds = true
        
        if storedGame!.image != nil {
            imageScene.image = UIImage(data: storedGame!.image!)
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
        
        if storedGame!.name != nil && storedGame!.name!.count != 0 {
            titleEntry.text = storedGame!.name!
        }
        
        if storedGame!.desc != nil && storedGame!.desc!.count != 0 {
            descriptionEntry.text = storedGame!.desc!
        }
        tags = storedGame!.tags ?? []
//        tags = GlobalInfo.tagList // TODO: Change with proper list for final
        
        if self.navigationController != nil {
            saveButton = UIBarButtonItem(title: "Save")
            self.navigationItem.rightBarButtonItem = saveButton
            saveButton?.target = self
            saveButton?.action = #selector(saveInfo)
        }
        
        tagDisplay.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: self.cellId)
        tagDisplay.delegate = self
        tagDisplay.dataSource = self
        
        tagButton.setTitle("Edit Tags", for: .normal)
        tagButton.setTitleColor(.white, for: .normal)
        tagButton.layer.backgroundColor = Color.primary.cgColor
        tagButton.layer.cornerRadius = 12
        tagButton.clipsToBounds = true
    }
    
    @objc
    func saveInfo() {
        storedGame?.name = titleEntry.text
        storedGame?.desc = descriptionEntry.text
        if shouldSaveImage {
            storedGame?.image = imageScene.image?.jpegData(compressionQuality: 0.9)
        }
        
        try! storedGame?.managedObjectContext?.save()
        navigationController?.popViewController(animated: true)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.tagDisplay.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! TagCell
        cell.labelView.text = tags[indexPath.row]
        cell.layer.cornerRadius = (collectionView.frame.height / 2) - 2 * cell.layer.borderWidth
        return cell
    }
    
    @IBAction func changeImage(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated:true)
    }
    
    @IBAction func tagAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TagView", bundle: nil)
        let tagView = storyboard.instantiateViewController(withIdentifier: "tagViewController") as! TagViewController
        
        tagView.delegate = self
        tagView.currentTags = storedGame?.tags
        
        self.navigationController?.pushViewController(tagView, animated: true)
    }
    
    func setGameTags(newTags: [String]) {
        if storedGame != nil {
            storedGame!.tags = newTags.map { $0 }
            tags = storedGame!.tags ?? []
            tagDisplay.reloadData()
        }
        else {
            print("storedGame is nil when trying to set tags")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
