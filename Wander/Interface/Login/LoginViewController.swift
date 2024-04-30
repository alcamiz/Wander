//
//  LoginViewController.swift
//  Wander
//
//  Created by Nihar Rao on 3/25/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = Color.primaryLogin
        
        loginButton.tintColor = Color.secondary
        loginButton.configuration?.baseForegroundColor = Color.background
        
        signupButton.tintColor = Color.background
        signupButton.configuration?.baseForegroundColor = Color.secondary
        
        formatTextField(emailTextField)
        formatTextField(passwordTextField)
        passwordTextField.isSecureTextEntry = true
        
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
    
    @IBAction func onLoginPressed(_ sender: Any) {
        if(emailTextField.text != nil && passwordTextField.text != nil ) {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                (authResult, error) in
                if (error as NSError?) != nil {
                    self.showAlert(message: "Invalid username or password")
                } else {
                    let user = StoredUser(context: GlobalInfo.managedContext!, username: "", id: authResult?.user.uid ?? "000000")
                    try? GlobalInfo.managedContext!.save()
                    self.performSegue(withIdentifier: "SuccessfulLoginSegue", sender: nil)
//                    Task {
//                        await storeAfterLogin(managedContext: GlobalInfo.managedContext!, userInfo: authResult!.user)
//                        self.performSegue(withIdentifier: "SuccessfulLoginSegue", sender: nil)
//                    }
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
