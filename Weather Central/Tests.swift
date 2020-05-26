//
//  Tests.swift
//  Weather Central
//
//  Created by George Bauer on 12/17/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import Foundation

func doTests() {
    var count = -1
    count += 1              // aviod warning
//    testRightJust();      count += 1          // StringExtension
//    testDoubleFormat();   count += 1          // OtherExtensions
//    testFormatLatLon();   count += 1          // Subs
//    testformatDbl();      count += 1
//    testMakeTimeStr();    count += 1
//    testShowCount();      count += 1
    print("Tests#\(#line)", showCount(count: count, name: "test", ifZero: "no"), "run\n")
}

//MARK:- StringExtension

func testRightJust() {
    print("\n🔶Test String.rightJust🔶")
    print("123456".rightJust(5))
    print("12345".rightJust(5))
    print("1234".rightJust(5))
    print("12".rightJust(5))
    print("".rightJust(5))
    print("🔶End Test String.rightJust🔶")
}

//MARK:- OtherExtensions.swift

func testDoubleFormat() {
    print("\n🔶Test testDoubleFormat🔶")
    print("fieldLength = 0")
    var dbl = 99.1225567
    print(dbl.format(fmt: ".3")," \t rounds(3) to .123") //rounds to .123
    dbl = -dbl
    print(dbl.format(fmt: ".3")," \t rounds(3) to .123") //rounds to .123
    dbl = 66.666666
    print(dbl.format(fmt: ".3")," \t rounds(3)")
    print(dbl.format(fmt: ".0"),"     \t rounds(0)")
    print("🔶End Test testDoubleFormat🔶")

}


//MARK:- Subs.swift

func testFormatLatLon() {
    print("\n🔶Test formatLatLon🔶")
    print(formatLatLon(lat: 28.5123, lon: -81.55123, places: 3))
    print(formatLatLon(lat: -89.12345, lon: -189.12345, places: 3))
    print(formatLatLon(lat: -89.12345, lon: -189.12345, places: 4))
    print(formatLatLon(lat: -89.12345, lon: -189.12345, places: 0))
    print("🔶End Test formatLatLon🔶")
}

func testformatDbl() {
    print("\n🔶Test testformatDbl🔶")
    print("fieldLength = 0")
    print(formatDbl(number: 99.1225567, fieldLen: 0, places: 3)," \t rounds(3) to .123") //rounds to .123
    print(formatDbl(number: -99.1225567, fieldLen: 0, places: 3)," \t rounds(3) to .123") //rounds to .123
    print(formatDbl(number: 66.666666, fieldLen: 0, places: 3)," \t rounds(3)")
    print(formatDbl(number: 66.666666, fieldLen: 0, places: 0),"     \t rounds(0)")
    let fLen = 7
    print("fieldLength = \(fLen)")
    print(formatDbl(number: -99.1225567, fieldLen: fLen, places: 4)," \t truncates(4)")
    print(formatDbl(number: 66.6666666, fieldLen: fLen, places: 5)," \t truncates(5)")
    print(formatDbl(number: 66.6666666, fieldLen: fLen, places: 4)," \t 66.6667 (4)")
    print(formatDbl(number: 66.6666666, fieldLen: fLen, places: 2)," \t ^^66.67 (2)")
    print(formatDbl(number: 66.6666666, fieldLen: fLen, places: 0)," \t ^^^^^67 (0)")
    print("🔶End Test testformatDbl🔶")
}

func testMakeTimeStr() {
    print("\n🔶Test makeTimeStr🔶")
    print(makeTimeStr(hrStr: "0",  minStr: "0", to24:  true),"   \t 00:00")
    print(makeTimeStr(hrStr: "7",  minStr: "1", to24:  true),"   \t 07:01")
    print(makeTimeStr(hrStr: "23", minStr:"59", to24:  true),"   \t 23:59")
    print(makeTimeStr(hrStr: "23", minStr:"59", to24: false)," \t 11:59pm")
    print(makeTimeStr(hrStr: "19", minStr: "0", to24: false)," \t  7:00pm")
    print(makeTimeStr(hrStr: "12", minStr: "0", to24: false)," \t 12:00pm")
    print(makeTimeStr(hrStr: "0",  minStr: "0", to24: false)," \t 12:00am")
    print("🔶End Test makeTimeStr🔶")
}

func testShowCount() {
    print("\n🔶Test testShowCount🔶")
    print(showCount(count: 0, name: "Thing", ifZero: "No"))
    print(showCount(count: 1, name: "Thing", ifZero: "No"))
    print(showCount(count: 2, name: "Thing", ifZero: "No"))
    print(showCount(count: 1, name: "try",   ifZero: "No"))
    print(showCount(count: 2, name: "try",   ifZero: "No"))
    print("🔶End Test testShowCount🔶")
}
