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
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = Color.secondary
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]

        self.navigationBar.standardAppearance = navAppearance
        self.navigationBar.scrollEdgeAppearance = navAppearance
    }

}
