//
//  LoginViewController.swift
//  Wander
//
//  Created by Nihar Rao on 3/25/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.primary
        loginButton.tintColor = Color.secondary
        
        formatTextField(emailTextField)
        formatTextField(passwordTextField)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        if(emailTextField.text != nil && passwordTextField.text != nil ) {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                (authResult, error) in
                if (error as NSError?) != nil {
                    self.showAlert(message: "Invalid username or password")
                } else {
                    //self.performSegue(withIdentifier: self.loginSegue, sender: nil)
                }
            }
        } else {
            showAlert(message: "Please enter both username and password")
        }
    }
    
    @IBAction func onSignupPressed(_ sender: Any) {
        
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Login", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func formatTextField(_ textField: UITextField) {
        // Adjust corner radius to make it rounded
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 10 // You can adjust the value as per your preference
        textField.layer.masksToBounds = true
        textField.textAlignment = .center
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
