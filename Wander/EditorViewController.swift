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
    
    var tile: StoredTile! // Incoming tile from MapView
    
    var titleTextField: UITextField!
    let defaultTitle = "Unnamed Tile"
    var tileTitle: String! // Saved tile title displayed on navigation bar
    
    @IBOutlet weak var imageView: UIImageView!
    var selectedImage: UIImage! // Saved image displayed in ImageView
    @IBOutlet weak var imagePlaceholder: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    let defaultText = "Enter text here..."
    var currentText: String! // Saved text displayed in TextView
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    var button1TextField: UITextField!
    var button2TextField: UITextField!
    var button1Title: String!
    var button2Title: String!
    let defaultButton1 = "Button 1"
    let defaultButton2 = "Button 2"
    var button1Option: StoredOption?
    var button2Option: StoredOption?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tile.image == nil {
            // Initially display ImageView with no image
            imagePlaceholder.text = "Image Here" // Placeholder text for where image is
            imagePlaceholder.textColor = UIColor.gray
            imagePlaceholder.isHidden = false
            
            // With no image in ImageView, add gray border to ImageView
            imageView.layer.borderWidth = 3
            imageView.layer.borderColor = UIColor.gray.cgColor
        } else {
            imageView.image = tile.fetchImage()
            imagePlaceholder.isHidden = true
        }
        
        // ImageView tappable; when tapped, can add image
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTapGesture)
        
        // TextView
        textView.delegate = self
        textView.isUserInteractionEnabled = true
        // Add border to textView
        textView.layer.borderWidth = 3
        textView.layer.borderColor = UIColor.black.cgColor
        if tile.text == nil {
            setDefaultText()
        } else {
            currentText = tile.text
            textView.text = tile.text
        }
        
        // Tile Title
        // Create a UITextField and set it as the titleView of the navigationItem
        titleTextField = UITextField()
        titleTextField.text = tile.title
        titleTextField.textAlignment = .center
        
        // Set the font to navigation bar text style (bold, point 17)
        titleTextField.font = UIFont.boldSystemFont(ofSize: 17)
        
        titleTextField.delegate = self
        navigationItem.titleView = titleTextField
        
        // Add a tap gesture recognizer to the navigation bar to handle editing
        let titleTapGesture = UITapGestureRecognizer(target: self, action: #selector(tileTitleTapped(_:)))
        titleTextField.addGestureRecognizer(titleTapGesture)
        
        // Add a tap gesture recognizer to the main view to dismiss the keyboard
        let mainViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(mainViewTapped(_:)))
        view.addGestureRecognizer(mainViewTapGesture)
        
        if (tile.options != nil && tile.options!.count >= 2) {
            let opts = tile.fetchAllOptions()
            button1Option = opts?[0]
            button2Option = opts?[1]
        } else {
            button1Option = tile.createOption(tile: nil, desc: defaultButton1)
            button2Option = tile.createOption(tile: nil, desc: defaultButton2)
        }
        
        // Create a UITextField with the same frame as the UIButtons
        button1TextField = UITextField(frame: button1.frame)
        button1Title = button1Option?.desc ?? defaultButton1
        button1.titleLabel?.text = button1Title
        button1TextField.isHidden = true
        button1TextField.delegate = self
        button1TextField.textAlignment = .center
        view.addSubview(button1TextField)
        
        button2TextField = UITextField(frame: button2.frame)
        button2Title = button2Option?.desc ?? defaultButton2
        button2.titleLabel?.text = button2Title
        button2TextField.isHidden = true
        button2TextField.delegate = self
        button2TextField.textAlignment = .center
        view.addSubview(button2TextField)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveToCore()
        super.viewWillDisappear(animated)
    }
    
    // Enables editing when title (in navigation bar) is tapped, and saves text to tileTitle when editing is done
    @objc func tileTitleTapped(_ sender: UITapGestureRecognizer) {
        // Enable editing when the title is tapped
        titleTextField.isUserInteractionEnabled = true
        titleTextField.becomeFirstResponder()
        titleTextField.selectAll(nil)
    }
    
    // When titleTextField is currently the first responder and the user taps outside of the text field/navigation bar, dismiss keyboard and end editing
    @objc func mainViewTapped(_ sender: UITapGestureRecognizer) {
        // Dismiss the keyboard when tapping outside the text field
        let location = sender.location(in: view)
        if !titleTextField.frame.contains(location) {
            titleTextField.resignFirstResponder()
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
    
    // Buttons
    
    // When user taps outside textView, display default text (if TextView is empty) or save text to currentText
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == nil || textView.text.isEmpty {
            setDefaultText()
        }
        else {
            currentText = textView.text!
        }
    }
    
    // Function to toggle between button title and text field for button 1
    func toggleEditButton1() {
        button1.titleLabel?.isHidden = !button1.titleLabel!.isHidden
        button1TextField.isHidden = !button1TextField.isHidden

        if !button1TextField.isHidden {
            // Set text field's text to button's current title
            button1TextField.text = button1.titleLabel?.text
            // Focus and select all text
            button1TextField.becomeFirstResponder()
            button1TextField.selectAll(nil)
        }
    }
    
    // Function to toggle between button title and text field for button 2
    func toggleEditButton2() {
        button2.titleLabel?.isHidden = !button2.titleLabel!.isHidden
        button2TextField.isHidden = !button2TextField.isHidden

        if !button2TextField.isHidden {
            // Set text field's text to button's current title
            button2TextField.text = button2.titleLabel?.text
            // Focus and select all text
            button2TextField.becomeFirstResponder()
            button2TextField.selectAll(nil)
        }
    }
    
    // When button1 pressed, edit button title
    @IBAction func button1Pressed(_ sender: UIButton) {
        toggleEditButton1()
    }
    
    // When button2 pressed, edit button title
    @IBAction func button2Pressed(_ sender: UIButton) {
        toggleEditButton2()
    }
    
    // UITextFieldDelegate method to handle end editing for button1
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == titleTextField {
            textField.resignFirstResponder()
            // Save the text from the text field into the titleText variable
            if let text = textField.text, text.isEmpty {
                // titleTextField is empty
                tileTitle = defaultTitle
                titleTextField.text = defaultTitle
            } else {
                // titleTextField is not empty
                tileTitle = titleTextField.text
            }
        }
        // Update button's title with text field's text
        if textField == button1TextField {
            if textField.text!.isEmpty {
                button1Title = nil // button 1 given no title
                button1.setTitle(defaultButton1, for: .normal) // display default title
            }
            else {
                button1Title = textField.text! // button 2's title is text field text
                button1.setTitle(button1Title, for: .normal) // display new title
            }
            
            // Reset title label's alignment and color
            button1.titleLabel?.textAlignment = .center
            button1.setTitleColor(.systemBlue, for: .normal)

            // Hide text field and show title label
            textField.isHidden = true
            button1.titleLabel?.isHidden = false
        }
        else if textField == button2TextField {
            if textField.text!.isEmpty {
                button2Title = nil // button 2 given no title
                button2.setTitle(defaultButton2, for: .normal) // display default title
            }
            else {
                button2Title = textField.text! // button 2's title is text field text
                button2.setTitle(button2Title, for: .normal) // display new title
            }
            
            // Reset title label's alignment and color
            button2.titleLabel?.textAlignment = .center
            button2.setTitleColor(.systemBlue, for: .normal)

            // Hide text field and show title label
            textField.isHidden = true
            button2.titleLabel?.isHidden = false
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
    
    func saveToCore() {
        if tileTitle != nil {
            tile.title = tileTitle
        }
        if currentText != nil {
            tile.text = currentText
        }
        if selectedImage != nil {
            tile.addImage(image: selectedImage)
        }
        if button1Option != nil && button1Title != nil {
            button1Option?.desc = button1Title
        }
        if button2Option != nil && button2Title != nil {
            button2Option?.desc = button2Title
        }
        
        try? self.tile.managedObjectContext?.save()
    }

    @IBAction func manualSave(_ sender: Any) {
        saveToCore()
    }
    
    @IBAction func linkButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Linking Tiles",
            message: "Select a button to link",
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(
            title: "Button One",
            style: .default,
            handler: {  (alert) in self.performSegue(withIdentifier: "LinkButtonOneSegue", sender: self)   }  ))
        controller.addAction(UIAlertAction(
            title: "Button Two",
            style: .default,
            handler: {  (alert) in self.performSegue(withIdentifier: "LinkButtonTwoSegue", sender: self)   }  ))
        present(controller, animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LinkButtonOneSegue",
           let nextVC = segue.destination as? LinkingViewController {
            nextVC.linkTitle = "Button One"
        } else if segue.identifier == "LinkButtonTwoSegue",
            let nextVC = segue.destination as? LinkingViewController{
            nextVC.linkTitle = "Button Two"
        }
    }
    
    
}
