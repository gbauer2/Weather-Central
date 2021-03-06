//
//  Globals.swift
//  Weather Central
//
//  Created by George Bauer on 10/18/17.
//  Copyright © 2017-2020 GeorgeBauer. All rights reserved.
//

import UIKit

//MARK: -------- Global Variables --------
var gDataIsCurrent = false
var globalDictJSON = NSDictionary()
var wuFeaturesArrEmpty = [false,false,false,false,false,false,false, false,false,false,false,false,false,false,false,false,false,false]
var wuFeaturesArr         = wuFeaturesArrEmpty      // WU Features that have been selected
var wuFeaturesWithDataArr = wuFeaturesArr           // Those Features with current data (not used)

//var gLastSearch = ""                    // The latest Search text from either Homepage or GeoLookup

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

// Features-Array Names - ????? should be struct
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
public enum UDKey {
    static let wuAPIKey        = "wuapikey"
    static let station         = "wuStationID"
    static let cityState       = "CityState"
    static let zip             = "Zip"
    static let lat             = "searchLat"
    static let lon             = "searchLon"
    static let lastSearch      = "LastSearch"
    static let searchType      = "searchType"
    static let featuresArr     = "wuFeaturesArray"
    static let featuresStr     = "wuFeatures"
    static let wuPlannerDate1  = "wuPlannerDate1"
    static let wuPlannerDate2  = "wuPlannerDate2"
    static let dateLastRun     = "dateLastRun"
    static let wuDateLastCall  = "wuDateLastCall"
    static let wuYmdLastCallET = "wuYmdLastCallET"
    static let wuNumCallsToday = "wuNumCallsToday"
}

//Convert to Struct ?????
public enum LocationSelectionType: String {
    case none = "none"
    case near = "Nearby"
    case city = "City"
    case zip  = "Zip"
    case latlon  = "LatLon"
    case station = "Station"
}

// segue identifiers
public struct SegueID {
    // Main.storyboard
    static let homeToSettings  = "segueSettings"
    static let homeToGeoLookup = "segueGeoLookup"
    static let homeToFeatures  = "segueFeatures"
    static let geoLookupToMap  = "segueGeoLookupToMap"
    // Settings.storyboard
    static let settingsToAPIKey       = "segueAPIKey"
    static let settingsToAbout        = "segueAbout"
    static let settingsToCallLimits   = "segueTestCallLimits"
}

public struct NotificationCenterKey {
    static let wuDownloadDone = "com.georgebauer.wuDownloadDoneNotification"
}
