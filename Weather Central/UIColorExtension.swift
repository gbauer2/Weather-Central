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
        let r, g, b, a: CGFloat

        if hexString.hasPrefix("#") {
            let hexColor = hexString.mid(begin: 1)

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >>  8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
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

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(
            red:   CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue:  CGFloat(b) / 0xff, alpha: 1
        )
    }
}
