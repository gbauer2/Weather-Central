//
//  UIColorExtension.swift
//  Weather Central
//
//  Created by George Bauer on 12/6/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import UIKit

extension UIColor {
    //------ initialize a UIColor with a Hex value ------
    public convenience init?(hexString: String) {

        if hexString.hasPrefix("#") {
            let hexColor = hexString.substring(begin: 1)

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    let red   = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    let green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    let blue  = CGFloat((hexNumber & 0x0000ff00) >>  8) / 255
                    let alpha = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }//end if scanner
            }//end if len == 8
        }//end if "#"
        return nil
    }
}

extension UIColor {
    //------ initialize a UIColor with a Hex value ------
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let red   = (rgbValue & 0xff0000) >> 16
        let green = (rgbValue & 0xff00) >> 8
        let blue  = rgbValue & 0xff

        self.init(
            red:   CGFloat(red)     / 0xff,
            green: CGFloat(green)   / 0xff,
            blue:  CGFloat(blue)    / 0xff, alpha: 1
        )
    }
}
