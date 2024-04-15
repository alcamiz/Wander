//
//  LandingViewController.swift
//  Wander
//
//  Created by Nihar Rao on 3/25/24.
//

import UIKit
import FirebaseAuth

class LandingViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        GlobalInfo.managedContext = appDelegate.persistentContainer.viewContext
        
        Auth.auth().addStateDidChangeListener() {
            (auth, user) in
            if user != nil {
                self.view.isHidden = true
                Task {
                    await storeAfterLogin(managedContext: GlobalInfo.managedContext!, userInfo: user!)
                    self.performSegue(withIdentifier: "PersistentSegue", sender: self)
                }
            }
            return
        }
        
        loginButton.tintColor = Color.secondary
        loginButton.setTitleColor(.white, for: .normal)
        
        signupButton.tintColor = .white
        signupButton.setTitleColor(Color.secondary, for: .normal)
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
