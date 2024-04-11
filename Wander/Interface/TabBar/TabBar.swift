//
//  TabBarController.swift
//  Wander
//
//  Created by Gabby G on 3/31/24.
//

import UIKit

class TabBar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.isTranslucent = false
        
        // Set the background color of the tab bar
        self.tabBar.backgroundColor = Color.secondary
        
        // Set the selected tab item color
        self.tabBar.tintColor = Color.primary
        
        // Set the unselected tab item color
        self.tabBar.unselectedItemTintColor = .white
        
    }
}
