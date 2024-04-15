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


class SignupViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = Color.primary
        
        signupButton.tintColor = Color.secondary
        signupButton.configuration?.baseForegroundColor = Color.background
        
        loginButton.tintColor = Color.background
        loginButton.configuration?.baseForegroundColor = Color.secondary
        
        formatTextField(usernameTextField)
        formatTextField(emailTextField)
        formatTextField(passwordTextField)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Login", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func onSignupPressed(_ sender: Any) {
        if(emailTextField.text != nil && passwordTextField.text != nil) {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                (authResult, error) in
                if (error as NSError?) != nil {
                    self.showAlert(message: "Invalid username or password.")
                } else {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let managedContext = appDelegate.persistentContainer.viewContext

                    if let userInfo = Auth.auth().currentUser,
                        let username = self.usernameTextField.text {
                        db.collection("users").document(userInfo.uid).setData([
                            "email": userInfo.email!,
                            "username": username,
                        ])
                        GlobalInfo.currentUser = storeAfterSignup(managedContext: managedContext, userInfo: userInfo, username: username)
                        self.performSegue(withIdentifier: "SuccessfulSignupSegue", sender: nil)

                    }

                }
            }
        } else {
            self.showAlert(message: "Please enter both username and password.")
        }
        print("wow!")
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
