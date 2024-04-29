//
//  TileCell.swift
//  Wander
//
//  Created by Alex Cabrera on 4/8/24.
//

import UIKit

class TileCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var firstLinkLabel: UILabel!
    @IBOutlet weak var secondLinkLabel: UILabel!

    @IBOutlet weak var tileCellImageView: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
