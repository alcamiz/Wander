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
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = Color.secondary
        
        self.tabBar.standardAppearance = tabAppearance
        self.tabBar.scrollEdgeAppearance = tabAppearance
        
        self.tabBar.isTranslucent = false
        
        // Set the selected tab item color
        self.tabBar.tintColor = Color.primary
                
    }
}
