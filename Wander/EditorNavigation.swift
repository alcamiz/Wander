//
//  EditorNavigation.swift
//  Wander
//
//  Created by Gabby G on 4/5/24.
//

import UIKit

class EditorNavigation: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.blue // change to hex value
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor:UIColor.white]
        
        self.navigationBar.standardAppearance = navAppearance
        self.navigationBar.scrollEdgeAppearance = navAppearance
    }
}
