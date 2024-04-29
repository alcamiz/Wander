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


class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, CropViewControllerDelegate {
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
        
        if let currentUser = GlobalInfo.currentUser {
            usernameLabel.text = "@\(currentUser.username ?? "unknownuser")"
            if let pic = currentUser.picture {
                profilePictureImageView.image = UIImage(data: pic)
                pfpLabel.text = ""
            }
        }
        
        usernameLabel.textColor = .gray

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //publishedGames
        guard let userID = GlobalInfo.currentUser?.id else {return}
        Task {
            publishedGames = await FirebaseHelper.gamesByAuthor(userID: userID)
            publishedGamesCollectionView.reloadData()
            FirebaseHelper.loadPictures(imageList: publishedGames, basepath: "gamePreviews") { (index, data) in
                self.publishedGames[index].image = data
                let indexPath = IndexPath(row: index, section: 0)
                self.publishedGamesCollectionView.reloadItems(at: [indexPath])
            }
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
        cell.authorLabel.text = game.authorUsername
        cell.imageView.backgroundColor = .secondarySystemBackground
        cell.imageView.image = if game.image != nil {
            UIImage(data: game.image!)
        } else {
            UIImage(systemName: "questionmark")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = collectionView.frame.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        return CGSize(width: 0.75 * height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ExploreCell
        
        Task {
            await UIView.animateKeyframes(withDuration: 0.1, delay: 0) {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/2) {
                    cell.alpha = 0.6
                }
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                    cell.alpha = 1
                }
            }
        }
        
        let storyboard = UIStoryboard(name: "GameScreen", bundle: nil)
        let gameScreen = storyboard.instantiateViewController(withIdentifier: "GameScreen") as! GameScreen
        gameScreen.infoGame = InfoGame(firebaseGame: publishedGames[indexPath.row])
        
        self.navigationController?.pushViewController(gameScreen, animated: true)
    }
    
    @IBAction func onLogOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            clearCoreData()
            navigateToLandingPage()
        } catch _ as NSError {
            print("error signing out")
        }
    }

    func clearCoreData() {
        let entities = ["StoredUser", "StoredTile", "StoredGame"]
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        entities.forEach { entityName in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetchRequest.returnsObjectsAsFaults = false

            do {
                let items = try context.fetch(fetchRequest)
                for item in items {
                    if let managedObject = item as? NSManagedObject {
                        context.delete(managedObject)
                    }
                }
            } catch let error {
                print("Error fetching \(entityName): \(error)")
            }
        }

        do {
            try context.save()
        } catch {
            print("Error saving after deleting entities: \(error)")
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
    
    @IBAction func onUpdatePasswordPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Update Password", message: "Enter your old password and new password", preferredStyle: .alert)

        alertController.addTextField { (oldPasstextField) in
            oldPasstextField.placeholder = "Old Password"
        }
        
        alertController.addTextField { (newPasstextField) in
            newPasstextField.placeholder = "New Password"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let updateAction = UIAlertAction(title: "Update", style: .default) { (_) in
            if let oldPassword = alertController.textFields?[0].text,
               let newPassword = alertController.textFields?[1].text {
                self.updatePassword(oldPassword: oldPassword, newPassword: newPassword)
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(updateAction)

        present(alertController, animated: true, completion: nil)
    }
    
    func updatePassword(oldPassword: String, newPassword: String) {
        guard let currentUser = Auth.auth().currentUser, let email = currentUser.email else {
            print("User not authenticated or email not found")
            return
        }

        // Re-authenticate the user
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        currentUser.reauthenticate(with: credential) { [weak self] authResult, error in
            if let error = error {
                print("Re-authentication failed:", error)
                return
            }

            // Proceed to update the password
            currentUser.updatePassword(to: newPassword) { error in
                if let error = error {
                    print("Password update failed:", error)
                    return
                }

                print("Password updated successfully")
                
                // Optionally, update the password in Firestore
                //self?.updateFirestorePassword(userID: currentUser.uid, newPassword: newPassword)
                
                // Update CoreData
                //self?.updateCoreDataPassword(newPassword: newPassword)
            }
        }
    }

    func updateFirestorePassword(userID: String, newPassword: String) {
        // Assuming you might want to store other user-related settings, but normally you should NOT store passwords in Firestore
        GlobalInfo.db.collection("users").document(userID).updateData(["password": newPassword]) { error in
            if let error = error {
                print("Failed to update password in Firestore:", error)
            } else {
                print("Firestore password updated successfully")
            }
        }
    }

    func updateCoreDataPassword(newPassword: String) {
        //GlobalInfo.currentUser?.password = newPassword
        do {
            try GlobalInfo.managedContext?.save()
            print("CoreData password updated successfully")
        } catch {
            print("Failed to save updated password in CoreData:", error)
        }
    }

    
//    func updatePassword(newPassword: String) {
//
//        guard let currentUserID = Auth.auth().currentUser?.uid else {
//            print("User not authenticated")
//            return
//        }
//
//        // Update in Firebase
//        GlobalInfo.db.collection("users").document(currentUserID)
//            .updateData(["username":newPassword])
//        
//        // Update in CoreData
//        GlobalInfo.currentUser?.username = newPassword
//        try! GlobalInfo.managedContext?.save()
//    }
    
    @IBAction func onHelpGuidePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Welcome to Wander!", message: "This app helps create choose your own adventure games easily. Here’s how you can get started:\n\n- On the task bar click on Explore to see and play games made by others.\n- Click on Create+ and create new game to make a game of your own! \n- You can create new tiles and link them together to create different options for the person playing your game \n\nExplore the app to discover more features! Have Fun! \n - Wander Team", preferredStyle: .alert)
                
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true)
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
