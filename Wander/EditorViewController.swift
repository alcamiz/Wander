//
//  EditorViewController.swift
//  Wander
//
//  Created by Benjamin Gordon on 2/28/24.
//  Edited by Gabrielle Galicinao
//
import CropViewController
import UIKit

class EditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var selectedImage: UIImage!
    @IBOutlet weak var imagePlaceholder: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initially display ImageView with no image
        imagePlaceholder.text = "Image Here" // Placeholder text for where image is
        imagePlaceholder.textColor = UIColor.gray
        imagePlaceholder.isHidden = false
        
        // With no image in ImageView, add gray border to ImageView
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.gray.cgColor
        
        // ImageView tappable; when tapped, can add image
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTapGesture)
    }
    
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

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        // Image selected
        selectedImage = image
        imageView.image = image
        
        // Do not show default settings
        imageView.layer.borderWidth = 0
        imagePlaceholder.isHidden = true
        
        picker.dismiss(animated: true, completion: nil)
//        showCrop(image: image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    /*
    func showCrop(image: UIImage) {
        let cropVC = CropViewController(croppingStyle: .default, image: image)
        cropVC.aspectRatioPreset = .presetSquare
        cropVC.aspectRatioLockEnabled = true
        cropVC.toolbarPosition = .top
        cropVC.doneButtonColor = .systemRed
        cropVC.cancelButtonColor = .systemRed
        cropVC.doneButtonTitle = "Done"
        cropVC.cancelButtonTitle = "Back"
        cropVC.delegate = self
        present(cropVC, animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        print("cropped")
    }
     */
}
