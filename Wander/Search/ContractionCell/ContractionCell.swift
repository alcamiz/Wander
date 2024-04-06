//
//  ContractionCell.swift
//  Wander
//
//  Created by Alex Cabrera on 4/2/24.
//

import UIKit

class ContractionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var mainLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.mainLabel.layer.borderWidth = 1.0
        self.mainLabel.textColor = .black
        
        self.setUnselected()
    }
    
    override func layoutSubviews() {
        
        self.mainLabel.font = self.mainLabel.font.withSize(self.frame.height * 2/3)
        self.mainLabel.layer.cornerRadius = self.frame.height / 2
        super.layoutSubviews()
    }
    
    func setUnselected() {
        self.mainLabel.layer.backgroundColor = UIColor.white.cgColor
        self.mainLabel.layer.borderColor = UIColor.black.cgColor
    }
    
    func setSelected() {
        self.mainLabel.layer.backgroundColor = Color.primary.cgColor
        self.mainLabel.layer.borderColor = Color.primary.cgColor
    }

}
