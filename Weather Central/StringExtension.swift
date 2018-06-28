//
//  myExtensions.swift
//  Weather Central
//
//  Created by George Bauer on 10/11/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//  Ver 1.1.1   2/16/2018
// String extensions

import Foundation

// String extensions: 
// subscript(i), subscript(range), left(i), right(i), mid(i,len), rightJust(len),
// indexOf(str), indexOfRev(str), trim(), contains(str), containsIgnoringCase(str), pluralize(n)
extension String {

    //------ subscript: allows string to be sliced be ints ------
    subscript (_ i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (_ i: Int) -> String {
        return String(self[i] as Character)
    }
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end   = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end   = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    //------ left: get the 1st n characters from self ------
    func left(_ length: Int) -> String {
        if length <= 0          { return "" }
        if length > self.count  { return self }
        let end = index(startIndex, offsetBy: length)
        return String(self[Range(startIndex ..< end)])
    }
    //------ right: get the last n characters from self ------
    func right(_ length: Int) -> String {
        let fullLen = self.count
        if length > fullLen || length < 0 {
            return self
        }
        let start = index(startIndex, offsetBy: fullLen - length)
        let end = index(startIndex, offsetBy: fullLen)
        return String(self[Range(start ..< end)])
    }

    //------ mid: extract a string starting at 'begin', of length ------
    func mid(begin: Int, length: Int = 0) -> String {
        let lenOrig = self.count                // length of subject str
        if begin > lenOrig || begin < 0  { return "" }

        var lenNew = length                     // length of extracted string
        if length == 0 ||  begin + length > lenOrig {
            lenNew = lenOrig - begin
        }

        let startIndexNew = index(startIndex, offsetBy: begin)
        let endIndex = index(startIndex, offsetBy: begin + lenNew)
        return String(self[Range(startIndexNew ..< endIndex)])
    }

    //------ rightJust: format right justify an int in self ------
    func rightJust(_ fieldLen: Int) -> String {
        guard self.count < fieldLen else { return self }
        let maxStr = String(repeating: " ", count: fieldLen)
        return (maxStr + self).right(fieldLen)
    }

    //------ indexOf, indexOfRev: find position of 2nd str in self ------
    func indexOf(searchforStr: String, startPoint: Int = 0) -> Int {
        let lenOrig = self.count
        let lenSearchFor = searchforStr.count
        var p = startPoint
        while p + lenSearchFor <= lenOrig {
            if self.mid(begin: p, length: lenSearchFor) == searchforStr {
                return p
            }
            p += 1
        }
        return -1
    }
    func indexOfRev(searchforStr: String) -> Int {
        let lenOrig = self.count
        let lenSearchFor = searchforStr.count
        var p = lenOrig - lenSearchFor
        while p >= 0 {
            if self.mid(begin: p, length: lenSearchFor) == searchforStr {
                return p
            }
            p -= 1
        }
        return -1
    }

    //------ trim(): remove whitespace at both ends ------
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
        //self.trimmingCharacters(in: .whitespaces)
    }

    //------ contains(str), containsIgnoringCase(str): does self contain str ------ Now Built-in to Swift
//    func contains(_ find: String) -> Bool{
//        return self.range(of: find) != nil
//    }
//    func containsIgnoringCase(_ find: String) -> Bool{
//        return self.range(of: find, options: .caseInsensitive) != nil
//    }

    //------ Pluralize a word (English) ------
    func pluralize(_ count: Int) -> String {
        if count == 1 || self.count < 2 {
            return self
        } else {
            let last2Chars =  self.right(2)
            let lastChar = last2Chars.right(1)
            let secondToLastChar = last2Chars.left(1)
            var prefix = "", suffix = ""

            if lastChar.lowercased() == "y" && vowels.filter({x in x == secondToLastChar}).count == 0 {
                prefix = self.left(self.count - 1)
                suffix = "ies"
            } else if (lastChar.lowercased() == "s" || (lastChar.lowercased() == "o")
                && consonants.filter({x in x == secondToLastChar}).count > 0) {
                prefix = self
                suffix = "es"
            } else {
                prefix = self
                suffix = "s"
            }
            return prefix + (lastChar != lastChar.uppercased() ? suffix : suffix.uppercased())
        }
    }
    private var vowels: [String] {
        get {
            return ["a", "e", "i", "o", "u"]
        }
    }
    private var consonants: [String] {
        get {
            return ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"]
        }
    }
}//end extension String


