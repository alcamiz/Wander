//
//  ResultCell.swift
//  Wander
//
//  Created by Alex Cabrera on 4/4/24.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var imageScreen: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        imageScreen.backgroundColor = .secondarySystemBackground
        imageScreen.layer.cornerRadius = 12
        imageScreen.clipsToBounds = true
        imageScreen.tintColor = .lightGray
        
        titleLabel.textColor = .black
        authorLabel.textColor = .lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
