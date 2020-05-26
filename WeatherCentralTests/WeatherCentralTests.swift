//
//  WeatherCentralTests.swift
//  WeatherCentralTests
//
//  Created by George Bauer on 5/25/20.
//  Copyright © 2020 GeorgeBauer. All rights reserved.
//

import XCTest
@testable import Weather_Central

class WeatherCentralTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_isStationValid() throws {
        //Bad Names
        XCTAssertEqual(isStationValid(nil),     false)
        XCTAssertEqual(isStationValid("BD"),    false)
        XCTAssertEqual(isStationValid("4BDR"),  false)
        XCTAssertEqual(isStationValid("BD,R"),  false)
        XCTAssertEqual(isStationValid("B DR"),  false)
        XCTAssertEqual(isStationValid("BD?R"),  false)
        XCTAssertEqual(isStationValid("9KN7"),  false)
        XCTAssertEqual(isStationValid("BDR1234567890"), false)
        XCTAssertEqual(isStationValid("A2B3C4D5E6F")  , false)
        //Good Names
        XCTAssertEqual(isStationValid("bdr"),   true)
        XCTAssertEqual(isStationValid("kbdr"),  true)
        XCTAssertEqual(isStationValid("9N7"),   true)
        XCTAssertEqual(isStationValid("K9N7"),  true)
        XCTAssertEqual(isStationValid("AABBCCDAEF7"), true)
    }

    func test_isZipValid() throws {
        //Bad text
        XCTAssertEqual(isZipValid(nil),     false)
        XCTAssertEqual(isZipValid("1234"),  false)
        XCTAssertEqual(isZipValid("-1234"), false)
        XCTAssertEqual(isZipValid("12.34"), false)
        //Good text
        XCTAssertEqual(isZipValid("01234"), true)

    }

    func test_getFirstPart() {
        XCTAssertEqual(getFirstPart(nil),  "")
        XCTAssertEqual(getFirstPart(""),  "")
        XCTAssertEqual(getFirstPart(":"),  "")
        XCTAssertEqual(getFirstPart(" ab : ba "),  "ab")
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
