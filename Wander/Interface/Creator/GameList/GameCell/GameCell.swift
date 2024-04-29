//
//  GameCell.swift
//  Wander
//
//  Created by Alex Cabrera on 4/8/24.
//

import UIKit

class GameCell: UITableViewCell {
    
    @IBOutlet weak var imageScene: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageScene.tintColor = .black
        imageScene.backgroundColor = .lightGray
        imageScene.layer.cornerRadius = 8
        imageScene.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
