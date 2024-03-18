//
//  EditorViewController.swift
//  Wander
//
//  Created by Benjamin Gordon on 2/28/24.
//

import UIKit

class EditorViewController: UIViewController, UITextViewDelegate {
    var tile: StoredTile!
    
    @IBOutlet weak var tileDescription: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tileDescription.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tileDescription.text = tile?.text ?? ""
        
        if tileDescription.text == "" {
            tileDescription.text = "Placeholder"
            tileDescription.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            tile.text = tileDescription.text
            try! tile.managedObjectContext?.save()
        }
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
