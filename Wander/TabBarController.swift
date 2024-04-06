//
//  TabBarController.swift
//  Wander
//
//  Created by Gabby G on 3/31/24.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.isTranslucent = false
        
        // Set the background color of the tab bar
        self.tabBar.backgroundColor = UIColor(rgb: 0x191970)
        
        // Set the selected tab item color
        self.tabBar.tintColor = UIColor(rgb: 0xADDAE6)
        
        // Set the unselected tab item color
        self.tabBar.unselectedItemTintColor = .white
        
    }
}
