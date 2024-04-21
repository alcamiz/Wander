//
//  ExploreNavigation.swift
//  Wander
//
//  Created by Alex Cabrera on 3/30/24.
//

import UIKit

class ExploreNavigation: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let primary = Color.secondary
        let secondary = UIColor.white
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = primary
        navAppearance.titleTextAttributes = [.foregroundColor: secondary]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: secondary]
        navAppearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: secondary, .backgroundColor: secondary]

        self.navigationBar.standardAppearance = navAppearance
        self.navigationBar.scrollEdgeAppearance = navAppearance
    }

}
