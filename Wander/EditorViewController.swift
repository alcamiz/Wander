//
//  EditorViewController.swift
//  Wander
//
//  Created by Benjamin Gordon on 2/28/24.
//  Edited by Gabrielle Galicinao
//
import CropViewController
import UIKit

class EditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var selectedImage: UIImage! // Saved image displayed in ImageView
    @IBOutlet weak var imagePlaceholder: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    let defaultText = "Enter text here..."
    var currentText: String! // Saved text displayed in TextView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedImage == nil {
            // Initially display ImageView with no image
            imagePlaceholder.text = "Image Here" // Placeholder text for where image is
            imagePlaceholder.textColor = UIColor.gray
            imagePlaceholder.isHidden = false
            
            // With no image in ImageView, add gray border to ImageView
            imageView.layer.borderWidth = 3
            imageView.layer.borderColor = UIColor.gray.cgColor
        }
        
        // ImageView tappable; when tapped, can add image
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTapGesture)
        
        // TextView
        textView.delegate = self
        textView.isUserInteractionEnabled = true
        textView.layer.borderWidth = 3
        textView.layer.borderColor = UIColor.black.cgColor
        if currentText == nil {
            setDefaultText()
        }
    }
    
    // ImageView
    
    // When ImageView tapped, displays alert that lets user add image from photo library or camera
    @objc func imageViewTapped() {
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
        imageView.layer.borderWidth = 0
        imagePlaceholder.isHidden = true
        
        // Update imageView and selectedImage with newly cropped image
        imageView.image = image
        selectedImage = image
    }
    
    // TextView
    
    // When TextView is empty, currentText is nil and placeholder text is in TextView
    func setDefaultText() {
        currentText = nil
        textView.textColor = UIColor.darkGray
        textView.text = defaultText
    }
    
    // When user taps inside textView, get rid of placeholder text
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == defaultText {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    // When user taps outside textView, display default text (if TextView is empty) or save text to currentText
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == nil || textView.text.isEmpty {
            setDefaultText()
        }
        else {
            currentText = textView.text!
        }
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
