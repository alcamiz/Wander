//
//  GameTitleViewController.swift
//  Wander
//
//  Created by Nihar Rao on 3/6/24.
//

import UIKit
import CropViewController

class GameTitleViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate {
    
    var delegate:UIViewController!
    
    // Label and text field for game title
    @IBOutlet weak var gameTitleLabel: UILabel!
    var gameTitleTextField: UITextField!

    let defaultGameTitle = "Unnamed Game" // Default game title displayed if user left text field empty/nil
    var gameTitle: String! // Saved game title
    
    
    @IBOutlet weak var gameImageView: UIImageView!
    var gameImage: UIImage!
    @IBOutlet weak var gameImagePlaceholder: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameTitleLabel.text = defaultGameTitle
        gameTitleLabel.isHidden = false // Display title
        gameTitleLabel.textAlignment = .center
        
        // Add text field where label is
        gameTitleTextField = UITextField(frame: gameTitleLabel.frame)
        gameTitleTextField.isHidden = true // Hide text field
        gameTitleTextField.textAlignment = .center
        
        gameTitleTextField.delegate = self
        view.addSubview(gameTitleTextField)
        
        // Add gesture recognizer for when user taps on title label to edit
        let gameTitleTapGesture = UITapGestureRecognizer(target: self, action: #selector(gameTitleTapped))
        gameTitleLabel.isUserInteractionEnabled = true
        gameTitleLabel.addGestureRecognizer(gameTitleTapGesture)
        
        
        if gameImage == nil {
            // Initially display ImageView with no image
            gameImagePlaceholder.text = "Image Here" // Placeholder text for where image is
            gameImagePlaceholder.textColor = UIColor.gray
            gameImagePlaceholder.isHidden = false
            
            // With no image in ImageView, add gray border to ImageView
            gameImageView.layer.borderWidth = 3
            gameImageView.layer.borderColor = UIColor.gray.cgColor
        }
        
        // ImageView tappable; when tapped, can add image
        let gameImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(gameImageViewTapped))
        gameImageView.isUserInteractionEnabled = true
        gameImageView.addGestureRecognizer(gameImageTapGesture)
    }
    
    @objc func gameImageViewTapped(_ sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: "Import Image", message: "Select image source", preferredStyle: .actionSheet)
        
        // Action that adds photo from camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(
                title: "Camera",
                style: .default) {_ in
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true, completion: nil)
            })
        }
        
        // Action that adds photo from photo library
        alertController.addAction(UIAlertAction(
            title: "Photo Library",
            style: .default) {_ in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
        })
        
        // Cancel action
        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel)
        )
        present(alertController, animated: true, completion: nil)
    }
    
    // When image selected from UIImagePickerController, dismiss and start cropping image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true, completion: nil) // Dismiss UIImagePickerController
        showCrop(image: image) // Crop image in CropViewController
    }

    // Dismiss UIImagePickerController when "Cancel" tapped
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Cropping images
    
    // Set up ViewController for cropping image
    func showCrop(image: UIImage) {
        let cropVC = CropViewController(croppingStyle: .default, image: image)
        cropVC.toolbarPosition = .top
        
        // Aspect ratio
        cropVC.aspectRatioPreset = .presetSquare
        cropVC.aspectRatioLockEnabled = true
        
        // Done button
        cropVC.doneButtonTitle = "Done"
        cropVC.doneButtonColor = .systemRed
        
        // Cancel button
        cropVC.cancelButtonTitle = "Back"
        cropVC.cancelButtonColor = .systemRed
     
        cropVC.delegate = self
        present(cropVC, animated: true)
    }
    
    // Dismiss CropViewController if "Cancel" tapped
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
    
    // When "Done" tapped, dismiss CropViewController and update imageView and selectedImage
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        
        // Do not show default settings
        gameImageView.layer.borderWidth = 0
        gameImagePlaceholder.isHidden = true
        
        // Update imageView and selectedImage with newly cropped image
        gameImageView.image = image
        gameImage = image
    }
    
    // When game title label is tapped, in edit mode
    @objc func gameTitleTapped(_ sender: UITapGestureRecognizer) {
        gameTitleLabel.isHidden = true // Hide label
        gameTitleTextField.isHidden = false // Display text field
        
        gameTitleTextField.isUserInteractionEnabled = true
        gameTitleTextField.becomeFirstResponder()
        gameTitleTextField.selectAll(nil)
    }
    
    // When user finishes editing text field, save contents
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Editing game title text field
        if textField == gameTitleTextField {
            // User leaves text field blank
            if textField.text == nil || textField.text!.isEmpty {
                gameTitle = nil // No game title is saved
                gameTitleLabel.text = defaultGameTitle // Display default title
            }
            else {
                gameTitle = textField.text! // Save text in text field
                gameTitleLabel.text = gameTitle // Display new game title
            }
            
            gameTitleLabel.isHidden = false // Display label
            textField.isHidden = true // Hide text field
        }
    }
    
    // Called when 'return' key pressed for all UITextFields
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of any of the UITextFields
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
