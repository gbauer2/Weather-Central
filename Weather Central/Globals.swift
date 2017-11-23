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
var wuFeaturesArrEmpty = [false,false,false,false,false,false,false, false,false,false,false,false,false,false,false,false,false,false]
var wuFeaturesArr         = wuFeaturesArrEmpty      // WU Features that have been selected
var wuFeaturesWithDataArr = wuFeaturesArr           // Those Features with current data (not used)

var gCityState = ""
var gZip       = ""
var gStation   = ""
var gLat = 0.0
var gLon = 0.0

var gLastSearch = ""

var gAPIKey = ""
var gPreviousAPIKey = ""
var gUserLat = 0.0
var gUserLon = 0.0
var gAppVersion = "0"
var gAppBuild   = "0"

//var gUserLocation = CLLocation(latitude: 0.0, longitude: 0.0)

//MARK: -------- Program Constants --------
// Background Colors for white on blue buttons
let colorButtonGray = UIColor(red: 0.82, green: 0.82,  blue: 0.84, alpha: 1)    //.lightGray (0x)
let colorButtonNorm = UIColor(red: 0.00, green: 0.478, blue: 1.00, alpha: 1)    //Blue       (0x007AFF)

// Features-Array Names - ???? should be eNum
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

// persistant storage: UserDefaults.standard.object Keys
public enum UDKey: String {
    case wuAPIKey    = "wuapikey"
    case station     = "wuStationID"
    case cityState   = "CityState"
    case zip         = "Zip"
    case lat         = "searchLat"
    case lon         = "searchLon"
    case lastSearch  = "LastSearch"
    case featuresArr = "wuFeaturesArray"
    case featuresStr = "wuFeatures"
    case wuPlannerDate1 = "wuPlannerDate1"
    case wuPlannerDate2 = "wuPlannerDate2"
    case dateLastRun    = "dateLastRun"
    case wuDateLastCall = "wuDateLastCall"
    case wuYmdLastCallET = "wuYmdLastCallET"
    case wuNumCallsToday = "wuNumCallsToday"
}

// segue identifiers
public enum segueID: String {
    case HomeToSettings  = "segueSettings"
    case HomeToGeoLookup = "segueGeoLookup"
    case HomeToFeatures  = "segueFeatures"
}
