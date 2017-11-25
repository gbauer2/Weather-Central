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

var gHomeSearchChanged = false          // Homepage Searchbox has changed since last return from GeoLookup
var gLastSearch = ""                    // The latest Search text from either Homepage or GeoLookup

var gAPIKey = ""                        // API Key
var gPreviousAPIKey = ""
var gUserLat = 0.0                      // User Lat from Location Sevices
var gUserLon = 0.0                      // User Lon from Location Sevices
var gAppVersion = "0"                   // App Version Number
var gAppBuild   = "0"                   // App Build Number

//var gUserLocation = CLLocation(latitude: 0.0, longitude: 0.0)

//MARK: -------- Program Constants --------
// Background Colors for white on blue buttons
let colorButtonGray = UIColor(red: 0.82, green: 0.82,  blue: 0.84, alpha: 1)    //.lightGray (0x)
let colorButtonNorm = UIColor(red: 0.00, green: 0.478, blue: 1.00, alpha: 1)    //Blue       (0x007AFF)

// Features-Array Names - ???? should be struct
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
public struct StructUDKey {
    let wuAPIKey        = "wuapikey"
    let station         = "wuStationID"
    let cityState       = "CityState"
    let zip             = "Zip"
    let lat             = "searchLat"
    let lon             = "searchLon"
    let lastSearch      = "LastSearch"
    let searchType      = "searchType"
    let mapReturnType   = "mapReturnType"
    let featuresArr     = "wuFeaturesArray"
    let featuresStr     = "wuFeatures"
    let wuPlannerDate1  = "wuPlannerDate1"
    let wuPlannerDate2  = "wuPlannerDate2"
    let dateLastRun     = "dateLastRun"
    let wuDateLastCall  = "wuDateLastCall"
    let wuYmdLastCallET = "wuYmdLastCallET"
    let wuNumCallsToday = "wuNumCallsToday"
}
public let UDKey = StructUDKey()
 
// segue identifiers
public struct SegueID {
    let HomeToSettings  = "segueSettings"
    let HomeToGeoLookup = "segueGeoLookup"
    let HomeToFeatures  = "segueFeatures"
    let GeoLookupToMap  = "segueGeoLookupToMap"
}
public let segueID = SegueID()
