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
        
        let primary = Color.primary
        let secondary = Color.secondary
        let complementary = Color.complementary
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = secondary
        navAppearance.titleTextAttributes = [.foregroundColor: complementary]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: complementary]
        navAppearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: primary, .backgroundColor: primary]

        self.navigationBar.standardAppearance = navAppearance
        self.navigationBar.scrollEdgeAppearance = navAppearance
    }

}
