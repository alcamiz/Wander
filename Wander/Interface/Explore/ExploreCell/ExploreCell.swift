//
//  FeatureCell.swift
//  Wander
//
//  Created by Alex Cabrera on 3/27/24.
//

import UIKit

class ExploreCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .black
        authorLabel.textColor = .lightGray
        
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.tintColor = .black
    }

}
