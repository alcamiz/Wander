//
//  ProfileViewController.swift
//  Wander
//
//  Created by Nihar Rao on 4/3/24.
//

import UIKit

import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import CoreData
import CropViewController

private var db = Firestore.firestore()
private var storage = Storage.storage().reference()

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate, CropViewControllerDelegate {
    
    let publishedGames: [StoredGame] = []
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var publishedGamesCollectionView: UICollectionView!
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publishedGamesCollectionView.dataSource = self
        publishedGamesCollectionView.delegate = self
        
        publishedGamesCollectionView.register(UINib(nibName: "ExploreCell", bundle: nil), forCellWithReuseIdentifier: "reUsable")

        // Do any additional setup after loading the view.
        
        // ImageView tappable; when tapped, can add image
        let gameImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(gameImageViewTapped))
        profilePictureImageView.isUserInteractionEnabled = true
        profilePictureImageView.addGestureRecognizer(gameImageTapGesture)
        
        profilePictureImageView.layer.borderWidth = 3
        profilePictureImageView.layer.borderColor = UIColor.gray.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //publishedGames
        
        publishedGamesCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return publishedGames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reUsable", for: indexPath) as! ExploreCell
        
        var game: StoredGame
        game = publishedGames[indexPath.row]
        
        cell.titleLabel.text = game.name
        cell.imageView.backgroundColor = .lightGray
//        cell.imageView.image = if game.image != nil {
//            UIImage(data: game.image!)
//        } else {
//            UIImage(systemName: "italic")
//        }
        return cell
    }
    
    @IBAction func onLogOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigateToLandingPage()
        } catch let error as NSError {
            print("error signing out")
        }
    }
    
    func navigateToLandingPage() {
        let storyboard = UIStoryboard(name: "LoginFlow", bundle: nil)
        if let landingVC = storyboard.instantiateViewController(withIdentifier: "LandingViewController") as? LandingViewController {
            
        landingVC.modalPresentationStyle = .fullScreen
        self.present(landingVC, animated: true, completion: nil)
//        navigationController?.pushViewController(landingVC, animated: true)
        }
    }
    
    @IBAction func onUpdateUsernamePressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Update Username", message: "Enter your new username", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "New Username"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let updateAction = UIAlertAction(title: "Update", style: .default) { (_) in
            if let newUsername = alertController.textFields?[0].text {
                self.updateUsername(newUsername: newUsername)
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(updateAction)

        present(alertController, animated: true, completion: nil)
    }
    
    func updateUsername(newUsername: String) {

        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        // Update in Firebase
        let userRef: Void = db.collection("users").document(currentUserID)
            .updateData(["username":newUsername])
        
        // Update in CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let res = try? managedContext.fetch(StoredUser.fetchRequest())
        res?[0].username = newUsername
        
        try! managedContext.save()
        
    }
    
    @IBAction func onUpdatePasswordPressed(_ sender: Any) {
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
        profilePictureImageView.layer.borderWidth = 0
        //gameImagePlaceholder.isHidden = true
        
        // Update imageView and selectedImage with newly cropped image
        profilePictureImageView.image = image
        //gameImage = image
//        game.addImage(image: image)
//        try? game.managedObjectContext?.save()
    }
}
