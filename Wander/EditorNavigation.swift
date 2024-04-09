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
        navAppearance.backgroundColor = Color.secondary
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]

        self.navigationBar.standardAppearance = navAppearance
        self.navigationBar.scrollEdgeAppearance = navAppearance
        
        changeButtonColorsInView(view: view)
    }
    
    // Function to change background color of UIButtons in a view
    private func changeButtonColorsInView(view: UIView) {
        for subview in view.subviews {
            if let button = subview as? UIButton {
                button.backgroundColor = Color.primary
                button.setTitleColor(Color.background, for: .normal)
            }
            // Recursively call this function for subviews
            if !subview.subviews.isEmpty {
                changeButtonColorsInView(view: subview)
            }
        }
    }
}
