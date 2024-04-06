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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
