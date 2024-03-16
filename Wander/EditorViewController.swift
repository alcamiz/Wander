//
//  EditorViewController.swift
//  Wander
//
//  Created by Benjamin Gordon on 2/28/24.
//

import UIKit

class EditorViewController: UIViewController, UITextViewDelegate {
    var tile: StoredTile!
    var empty: Bool = false
    
    @IBOutlet weak var tileDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tileDescription.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tileDescription.text = tile?.text ?? ""
        
        if tileDescription.text == "" {
            tileDescription.text = "Placeholder"
            tileDescription.textColor = UIColor.lightGray
            empty = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            if !empty {tile.text = tileDescription.text}
            try! tile.managedObjectContext?.save()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            empty = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
            empty = true
        }
    }
}
