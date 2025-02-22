// Color.swift
// Wander
//
// Created by Nihar Rao on 4/1/24.

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexValue = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexValue.hasPrefix("#") {
            hexValue.remove(at: hexValue.startIndex)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

class Color {
    
    // Blue
    static let primary = UIColor(hex: "#64A0Ef") // light blue
    static let secondary = UIColor(hex: "#191970") // dark blue
    static let complementary = UIColor.white // opposite color, for text
    
    // Blue
    static let primaryLogin = UIColor(hex: "#ADDAE6") // light blue
    static let secondaryLogin = UIColor(hex: "#191970") // dark blue
    
    // Green
    static let primaryGreen = UIColor(hex: "#74A672") // light green
    static let secondaryGreen = UIColor(hex: "#055902") // dark green
    
    static let background = UIColor(hex: "#FFFFFF") // white
    static let systemPink = UIColor(hex: "#FF2D55") // delete button
}
