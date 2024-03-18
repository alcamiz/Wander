//
//  GameTitleViewController.swift
//  Wander
//
//  Created by Nihar Rao on 3/6/24.
//

import UIKit

class GameTitleViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var delegate:UIViewController!
    
    // Label and text field for game title
    @IBOutlet weak var gameTitleLabel: UILabel!
    var gameTitleTextField: UITextField!

    let defaultGameTitle = "Unnamed Game" // Default game title displayed if user left text field empty/nil
    var gameTitle: String! // Saved game title
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameTitleLabel.text = defaultGameTitle
        gameTitleLabel.isHidden = false // Display title
        
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
