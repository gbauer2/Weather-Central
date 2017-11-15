//
//  Globals.swift
//  Weather Central
//
//  Created by George Bauer on 10/18/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import UIKit

//MARK: -------- Global Variables --------
var gDataIsCurrent = false
var globalDictJSON = NSDictionary()
var wuFeaturesArr = [false,false,false,false,false,false,false, false,false,false,false,false,false,false,false,false,false,false]
var wuFeaturesWithDataArr = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]
var gCity = ""
var gState = ""
var gAPIKey = ""
var gPreviousAPIKey = ""
var gStationID = ""
var gUpdateGeoLookup = true
var gUserLat = 0.0
var gUserLon = 0.0
var gAppVersion = "0"
var gAppBuild   = "0"

//var gUserLocation = CLLocation(latitude: 0.0, longitude: 0.0)

//MARK: -------- Program Constants --------
// Background Colors for white on blue buttons
let colorButtonGray = UIColor(red: 0.82, green: 0.82,  blue: 0.84, alpha: 1)    //.lightGray (0x)
let colorButtonNorm = UIColor(red: 0.00, green: 0.478, blue: 1.00, alpha: 1)    //Blue       (0x007AFF)

// Features-Array Names
let iAlerts      = 1
let iAlmanac     = 2
let iAstronomy   = 3
let iConditions  = 4
let iHurricane   = 5
let iForecast    = 6
let iForecast10day = 7
let iGeolookup   = 8
let iHistory     = 9
let iHourly      = 10
let iHourly10Day = 11
let iPlanner     = 12
let iRawTide     = 13
let iSatellite   = 14
let iTide        = 15
let iWebcams     = 16
let iYesterday   = 17
