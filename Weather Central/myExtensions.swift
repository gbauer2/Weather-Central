//
//  myExtensions.swift
//  Weather Central
//
//  Created by George Bauer on 10/11/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import UIKit
extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[Range(start ..< end)]
    }
    func left(_ length: Int) -> String {
        if length > self.count {
            return self
        }
        let end = index(startIndex, offsetBy: length)
        return self[Range(startIndex ..< end)]
    }
    func right(_ length: Int) -> String {
        let fullLen = self.count
        if length > fullLen || length < 0 {
            return self
        }
        let start = index(startIndex, offsetBy: fullLen - length)
        let end = index(startIndex, offsetBy: fullLen)
        return self[Range(start ..< end)]
    }
    func rightJust(_ fieldLen: Int) -> String {
        if self.count >= fieldLen {
            return self
        }
        var s = self
        for _ in 1...fieldLen - self.count {
            s = " " + s
        }
        return s
    }
    
    func mid(begin: Int, length: Int = 0) -> String {
        let lenOrig = self.count
        var lenNew = lenOrig
        if length > 0  {lenNew = length}
        if begin > lenOrig || begin < 0  {
            return ""
        }
        if begin + length > lenOrig {
            lenNew = lenOrig - begin
        }
        let startIndexNew = index(startIndex, offsetBy: begin)
        let endIndex = index(startIndex, offsetBy: begin + lenNew)
        return self[Range(startIndexNew ..< endIndex)]
    }
    func indexOf(searchforStr: String) -> Int {
        let lenOrig = self.count
        let lenSearchFor = searchforStr.count
        var p = 0
        while p + lenSearchFor <= lenOrig {
            if self.mid(begin: p, length: lenSearchFor) == searchforStr {
                return p
            }
            p += 1
        }
        return -1
    }
}


extension UIColor {
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
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
