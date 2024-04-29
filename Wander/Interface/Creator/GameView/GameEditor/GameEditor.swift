//
//  GameEditor.swift
//  Wander
//
//  Created by Alex Cabrera on 4/14/24.
//

import UIKit
import CropViewController

class GameEditor: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, ModifyGameTagsDelegate, UITextFieldDelegate, CropViewControllerDelegate {
    
    // Updateable UI fields
    @IBOutlet weak var imageScene: UIImageView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var titleEntry: UITextField!
    @IBOutlet weak var descriptionEntry: UITextView!
    @IBOutlet weak var tagDisplay: UICollectionView!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let picker = UIImagePickerController()
    var storedGame: StoredGame?
    var saveButton: UIBarButtonItem?
    var shouldSaveImage = false
    let cellId = UUID().uuidString
    var tags: [String] = []
    var keyboardConstrained = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureReconizer)
        
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
        
        titleEntry.delegate = self
        
        if storedGame!.name != nil && storedGame!.name!.count != 0 {
            titleEntry.text = storedGame!.name!
        }
        
        if storedGame!.desc != nil && storedGame!.desc!.count != 0 {
            descriptionEntry.text = storedGame!.desc!
        }
        tags = storedGame!.tags ?? []
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // adding notification observers for keyboard show and hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
         
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
     
      // removing all the notification observers
      NotificationCenter.default.removeObserver(self)
   }
    
    @objc
    func dismissKeyboard() {
        titleEntry.endEditing(true)
        descriptionEntry.endEditing(true)
    }
    
    @objc
    func saveInfo() {
        storedGame?.name = titleEntry.text
        storedGame?.desc = descriptionEntry.text
        if shouldSaveImage {
            storedGame?.image = imageScene.image?.jpegData(compressionQuality: 0.9)
        }
        storedGame?.tags = tags
        
        try? storedGame?.managedObjectContext?.save()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Tag Handling
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.tagDisplay.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! TagCell
        cell.labelView.text = tags[indexPath.row]
        cell.layer.cornerRadius = (collectionView.frame.height / 2) - 2 * cell.layer.borderWidth
        return cell
    }
    
    // Open TagList to modify currently selected tags
    @IBAction func tagAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TagView", bundle: nil)
        let tagView = storyboard.instantiateViewController(withIdentifier: "tagViewController") as! TagViewController
        
        tagView.delegate = self
        tagView.currentTags = tags
        
        self.navigationController?.pushViewController(tagView, animated: true)
    }
    
    // Send back selected tags, called from TagList
    func setGameTags(newTags: [String]) {
        tags = newTags
        tagDisplay.reloadData()
    }
    
    // MARK: - Image Handling
    
    @IBAction func changeImage(_ sender: Any) {
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
    
    // Set up ViewController for cropping image
    func showCrop(image: UIImage) {
        let cropVC = CropViewController(croppingStyle: .default, image: image)
        cropVC.toolbarPosition = .top
        
        // Aspect ratio
        cropVC.aspectRatioPreset = .presetSquare
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
    
    // When "Done" tapped, dismiss CropViewController and update imageView and selectedImage
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
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
       
       // move the text field when editing
        updateViewWithKeyboard(notification: notification, viewBottomConstraint: self.bottomConstraint!, keyboardWillShow: true)
    }

    @objc private func keyboardWillHide(_ notification: NSNotification) {

       // move the field back to the previous position after editing is done
       updateViewWithKeyboard(notification: notification, viewBottomConstraint: self.bottomConstraint!, keyboardWillShow: false)
    }
    
    private func updateViewWithKeyboard(notification: NSNotification,
    viewBottomConstraint: NSLayoutConstraint,
    keyboardWillShow: Bool) {

       // getting keyboard size
       guard let userInfo = notification.userInfo,
       let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
          return
       }

       // getting duration for keyboard animation
       guard let keyboardDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
          return
       }

       // getting keyboard animation's curve
       guard let keyboardCurve = UIView.AnimationCurve(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int) else {
          return
       }

       // getting keyboard height
       let keyboardHeight = keyboardSize.cgRectValue.height - 100

        // setting constant for keyboard show and hide
        if keyboardWillShow {
            if !keyboardConstrained {
                viewBottomConstraint.constant += keyboardHeight
                keyboardConstrained = true
            }
        } else {
            if keyboardConstrained {
                viewBottomConstraint.constant -= keyboardHeight
                keyboardConstrained = false
            }
        }

       // animate the view the same way the keyboard animates
       let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) {
          [weak self] in self?.view.layoutIfNeeded()
       }

       // perform the animation
       animator.startAnimation()
    }
}
