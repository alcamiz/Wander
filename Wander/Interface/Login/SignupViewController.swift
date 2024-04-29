//
//  SignupViewController.swift
//  Wander
//
//  Created by Nihar Rao on 3/25/24.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import CoreData

private var db = Firestore.firestore()


class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = Color.primaryLogin
        
        signupButton.tintColor = Color.secondary
        signupButton.configuration?.baseForegroundColor = Color.background
        
        loginButton.tintColor = Color.background
        loginButton.configuration?.baseForegroundColor = Color.secondary
        
        formatTextField(usernameTextField)
        formatTextField(emailTextField)
        formatTextField(passwordTextField)
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
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
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Login", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func onSignupPressed(_ sender: Any) {
        guard emailTextField.text != nil && passwordTextField.text != nil && usernameTextField.text != nil else {
            self.showAlert(message: "Please enter both email, username and password.")
            return
        }
        
        Task {
            let usernameTaken = await FirebaseHelper.usernameAlreadyExists(username: usernameTextField.text!)
            guard !usernameTaken else {
                self.showAlert(message: "Username \(usernameTextField.text!) is already in use.")
                return
            }
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                (authResult, error) in
                guard (error as NSError?) == nil else {
                    self.showAlert(message: "Invalid email or password.")
                    return
                }
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let managedContext = appDelegate.persistentContainer.viewContext

                
                if let userInfo = Auth.auth().currentUser,
                    let username = self.usernameTextField.text {
                    db.collection("users").document(userInfo.uid).setData([
                        "email": userInfo.email!,
                        "username": username,
                        "liked": [:] 
                    ])
                    GlobalInfo.currentUser = storeAfterSignup(managedContext: managedContext, userInfo: userInfo, username: username)
                    self.performSegue(withIdentifier: "SuccessfulSignupSegue", sender: nil)
                }
            }
        }
    }
    
    
    func formatTextField(_ textField: UITextField) {
        // Adjust corner radius to make it rounded
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 17
        textField.layer.masksToBounds = true
        textField.textAlignment = .left
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
