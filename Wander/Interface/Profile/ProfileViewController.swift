//
//  ProfileViewController.swift
//  Wander
//
//  Created by Nihar Rao on 4/3/24.
//

import UIKit

import FirebaseAuth
import CoreData
import CropViewController


class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate, CropViewControllerDelegate {
    var publishedGames: [FirebaseGame] = []
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var publishedGamesCollectionView: UICollectionView!
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    @IBOutlet weak var pfpLabel: UILabel!
    
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
        
        if let currentUser = GlobalInfo.currentUser {
            usernameLabel.text = currentUser.username
            if let pic = currentUser.picture {
                profilePictureImageView.image = UIImage(data: pic)
                pfpLabel.text = ""
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //publishedGames
        guard let userID = GlobalInfo.currentUser?.id else {return}
        Task {
            publishedGames = await FirebaseHelper.gamesByAuthor(userID: userID)
            publishedGamesCollectionView.reloadData()
        }
       
       
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return publishedGames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reUsable", for: indexPath) as! ExploreCell
        
        var game: FirebaseGame
        game = publishedGames[indexPath.row]
        
        cell.titleLabel.text = game.name
        cell.imageView.backgroundColor = .secondarySystemBackground
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
        } catch _ as NSError {
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
        GlobalInfo.db.collection("users").document(currentUserID)
            .updateData(["username":newUsername])
        
        // Update in CoreData
        GlobalInfo.currentUser?.username = newUsername
        try! GlobalInfo.managedContext?.save()

        usernameLabel.text = newUsername
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
        if let compressedData = image.jpegData(compressionQuality: 0.75),
           let userID = GlobalInfo.currentUser?.id {
            profilePictureImageView.image = UIImage(data: compressedData)
            
            GlobalInfo.currentUser?.picture = compressedData
            try! GlobalInfo.managedContext?.save()
            
            let imagePathRef = GlobalInfo.storage.child("userProfiles/\(userID).jpeg")
            let _ = imagePathRef.putData(compressedData, metadata: nil)
            pfpLabel.text = ""
        }
    }
}
