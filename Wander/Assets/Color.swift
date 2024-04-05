//
//  File.swift
//  Wander
//
//  Created by Nihar Rao on 4/1/24.
//

import UIKit

class Color {
    
    // Blue
    static let primary = UIColor(hex: "#ADDAE6") // light blue
    static let secondary = UIColor(hex: "#191970") // dark blue
    
    // Green
    static let primaryGreen = UIColor(hex: "#74A672") // light green
    static let secondaryGreen = UIColor(hex: "#055902") // dark green
    
    static let background = UIColor(hex: "#FFFFFF") // white
}

extension UIColor {
    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        var rgbValue: UInt64 = 0

        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

