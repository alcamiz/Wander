//
//  TagCell.swift
//  Wander
//
//  Created by Alex Cabrera on 4/15/24.
//

import UIKit

class TagCell: UICollectionViewCell {

    @IBOutlet weak var labelView: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.black.cgColor
        
        self.labelView.textColor = .black
        self.labelView.adjustsFontForContentSizeCategory = true
    }
    
    func setUnselected() {
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    func setSelected() {
        self.layer.backgroundColor = Color.primary.cgColor
        self.layer.borderColor = Color.primary.cgColor
    }

}
