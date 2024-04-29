//
//  TagTableViewCell.swift
//  Wander
//
//  Created by Gabby G on 4/17/24.
//

import UIKit

class TagTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var checkedButton: UIButton!
    var isChecked = false
    var delegate: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addCheck()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            toggleChecked()
        }
        else {
            addCheck()
        }
    }
    
    func addCheck() {
        if isChecked {
            checkedButton.isHidden = false
        }
        else {
            checkedButton.isHidden = true
        }
    }
    
    func toggleChecked() {
        print("selected")
        let tagVC = delegate as! ModifyTagDelegate
        
        if isChecked {
            isChecked = false
            checkedButton.isHidden = true
            tagVC.removeTag(tagName: tagLabel.text!)
        }
        else {
            isChecked = true
            checkedButton.isHidden = false
            tagVC.addTag(tagName: tagLabel.text!)
        }
    }
}
