//
//  wuSubs.swift
//  Weather Central
//
//  Created by George Bauer on 10/1/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//
// ------ Subroutines for Weather Underground API ------

import Foundation

//MARK: ---- Structures ----

struct Station {
    public let type:        String      //AP or pws
    public let id:          String      //
    public let city:        String
    public let neighborhood: String
    public let state:       String
    public let country:     String
    public let lat:         Double
    public let lon:         Double
    // init from Dictionary with lat & lon defined a Double OR String
    public init(sta: [String: Any]) {
        var type        = ""
        var id          = sta["id"] as? String ?? ""
        if id == "" {
            type        = "Airport"
            id          = sta["icao"] as? String ?? ""
        } else {
            type        = "pws"
        }
        let city         = sta["city"] as? String ?? ""
        let neighborhood = sta["neighborhood"] as? String ?? ""
        let state        = sta["state"] as? String ?? ""
        let country      = sta["country"] as? String ?? ""
        let olat         = sta["lat"]
        let olon         = sta["lon"]
        
        self.type         = type
        self.id           = id
        self.city         = city
        self.neighborhood = neighborhood
        self.state        = state
        self.country      = country
        
        if olat is Double {
            self.lat = olat as! Double
        } else if olat is String {
            if let lat = Double(olat as! String) {
                self.lat = lat
            } else {
                self.lat = 0.0
            }
        } else {
            self.lat = 0.0
        }
        
        if olon is Double {
            self.lon = olon as! Double
        } else if olon is String {
            if let lon = Double(olon as! String) {
                self.lon = lon
            } else {
                self.lon = 0.0
            }
        } else {
            self.lon = 0.0
        }
    }
}

// ------ StationInfo Struct ------
struct StationInfo {
    public let type:     String
    public let id:       String
    public let distMi:   Double
    public let dir:      Int
    public let lineItem: String
    public let detail:   String

    public init(type: String, id: String, distMi: Double, dir: Int, lineItem: String, detail: String) {
        self.type     = type
        self.id       = id
        self.distMi   = distMi
        self.dir      = dir
        self.lineItem = lineItem
        self.detail   = detail
    }
}

// ------ Location Struct ------
struct Location {
    public let type:       String       // "INTLCITY"
    public let city:       String       // "Montreal"
    public let state:      String       // "QC"
    public let state_name: String
    public let zip:        String       // "00000"
    public let country:    String       // "CA"
    public let country_iso3166: String  // "CA"
    public let country_name: String     // "Canada"
    public let full:       String
    public let elevation:  String
    public let lat:        String       // "45.50999832"
    public let lon:        String       // "-73.55000305"
    public let tz_long:    String       // "America/Toronto"
    public let tz_short:   String       // "EDT"
    public let requesturl: String       // "global/stations/71612.html"
    public let wuiurl:     String       // "https://www.wunderground.com/global/stations/7161"
    //??nearby_weather_stations -> {Dictionary} with 2 items
    //??l --------------------> "/q/zmw:00000.94.71612"
    //??wmo ------------------> "71612"
    //??magic ----------------> "94"

    // init from a dictionary
    public init(loc: [String: Any]) {
//        guard let loc = json["location"] as? [String: Any] else { return nil }
        let type        = loc["type"]       as? String ?? ""
        let city        = loc["city"]       as? String ?? ""
        let state       = loc["state"]      as? String ?? ""
        let state_name  = loc["state_name"] as? String ?? ""
        let zip         = loc["zip"]        as? String ?? ""
        let country     = loc["country"]    as? String ?? ""
        let country_iso3166 = loc["country_iso3166"] as? String ?? ""
        let country_name = loc["country_name"] as? String ?? ""
        let full        = loc["full"]       as? String ?? ""
        let elevation   = loc["elevation"]  as? String ?? ""
        let lat         = loc["lat"]        as? String ?? ""
        let lon         = loc["lon"]        as? String ?? ""
        let latitude    = loc["latitude"]   as? String ?? ""
        let longitude   = loc["longitude"]  as? String ?? ""
        let tz_long     = loc["tz_long"]    as? String ?? ""
        let tz_short    = loc["tz_short"]   as? String ?? ""
        let requesturl  = loc["requesturl"] as? String ?? ""
        let wuiurl      = loc["wuiurl"]     as? String ?? ""
        //-----------------------------
        self.type       = type
        self.city       = city
        self.state      = state
        if state_name != "" {
            self.state_name = state_name
        } else {
            self.state_name = state
        }
        self.zip        = zip
        self.country    = country
        self.country_iso3166 = country_iso3166
        self.country_name = country_name
        if full != "" {
            self.full = full
        } else {
            if country == "US" && state != "" {
                self.full = city + ", " + state
            } else if country_name != ""  {
                self.full = city + ", " + country_name
            } else if country != ""  {
                self.full = city + ", " + country
            } else {
                self.full = city
            }
        }
        self.elevation  = elevation
        if lat == "" && lon == "" {
            self.lat        = latitude
            self.lon        = longitude
        } else {
            self.lat        = lat
            self.lon        = lon
        }
        self.tz_long    = tz_long
        self.tz_short   = tz_short
        self.requesturl = requesturl
        self.wuiurl     = wuiurl
    }//end init
    
}//end struct Location

//MARK: ---- Subs ----
//      Make URL from "myAPIKey", "features", and "place" -> returns (url,error)
public func makeWuUrlJson(APIKey: String, features: String, place: String) -> (url: URL, errorStr: String) {
    var featuresX = features
    if !features.hasSuffix("/") { featuresX = featuresX + "/" }
    let placeX = place.replacingOccurrences(of: " ", with: "_")
    let urlStr = "https://api.wunderground.com/api/\(APIKey)/\(featuresX)q/\(placeX).json"
    guard let url = URL(string: urlStr) else {
        let errorStr = "Err201 in URL: \(urlStr)"
        print("\n\(errorStr)")
        return (URL(string: "www.dummy.com")!, errorStr)
    }//end guard
    print("🙂 URL (\(urlStr)) created")
    return (url, "")
}

//MARK: -------- Checks for valid text inputs --------
public func getSearchType(searchText: String) -> LocationSelectionType {
    if isLocalValid(searchText)     { return .near }
    if isZipValid(searchText)       { return .zip }
    if isLatLonValid(searchText)    { return .latlon }
    if isStationValid(searchText)   { return .station }
    if isCityStateValid(searchText) { return .city }
    return .none
}

public func isLocalValid(_ text: String) -> Bool {
    let txt = getFirstPart(text).lowercased()
    if txt == "" || txt == "local" || txt == "near" || txt == "nearby" || txt == "me" { return true }
    return false
}

// Station has 3-4 chars for AP, mixed letters & digits for pws
public func isStationValid(_ stationName: String) -> Bool {
    let sta = stationName.trim
    let n = sta.count
    if n < 3 || n > 11    { return false }
    if sta.contains(",") || sta.contains(" ")  { return false }

    let letters = CharacterSet.letters
    let digits = CharacterSet.decimalDigits

    for uni in stationName.unicodeScalars {
        if !letters.contains(uni) && !digits.contains(uni) { return false }
    }
    //if n>3 1st char must be a letter
    //ToDo: if n=4 then no digits allowed
    if n > 3 {
        if !letters.contains(stationName.unicodeScalars.first!) { return false }

        //if n>4 last char must be digit
        if n > 4 {
            if !digits.contains(stationName.unicodeScalars.last!) { return false }
        }
    }
    return true
}

public func isCityStateValid(_ cityState: String) -> Bool {
    if cityState.count < 4      { return false }
    if !cityState.contains(",") { return false }
    if cityState.IndexOf(searchforStr: ",") > cityState.count - 3 { return false }
    //?????check for legal chars letters, " ", ","

    let letters = CharacterSet.letters
    //let digits = CharacterSet.decimalDigits

    for uni in cityState.unicodeScalars {
        if !letters.contains(uni) && uni != " " && uni != "," && uni != "."
            { return false }
    }
    return true
}

public func isZipValid(_ zip: String) -> Bool {
    let zp = getFirstPart(zip)
    if zp.count != 5 {return false}
    if Int(zp) != nil {return true}
    return false
}

public func isLatValid(_ latTxt: String) -> Bool {
    return getLat(latTxt) != nil
}

public func isLonValid(_ lonTxt: String) -> Bool {
    return getLon(lonTxt) != nil
}

public func getLat(_ latTxt: String) -> Double? {
    if latTxt.count < 2                 {return nil}  // < 2 chars in Lat
    var latStr = latTxt.uppercased()
    latStr = latStr.replacingOccurrences(of: "°", with: "")     // remove degree sign
    var isSouth = false

    if latStr.contains("S") {
        if latStr.contains("-") { return nil }
        isSouth = true
        latStr = latStr.replacingOccurrences(of: "S", with: "")
    }
    if latStr.contains("N") {
        if isSouth { return nil }
        if latStr.contains("-") { return nil }
        latStr = latStr.replacingOccurrences(of: "N", with: "")
    }
    guard let latt = Double(latStr.trim) else {return nil}  // Lat is not a number
    var lat = latt
    if isSouth { lat = -latt }
    if lat < -90.0 || lat > 90.0        {return nil}  // Lat out-of bounds
    return lat
}

public func getLon(_ lonTxt: String ) -> Double? {
    if lonTxt.count < 2                 {return nil}  // < 2 chars in Lon
    var lonStr = lonTxt.uppercased()
    lonStr = lonStr.replacingOccurrences(of: "°", with: "")     // remove degree sign
    var isWest = false

    if lonStr.contains("W") {
        if lonStr.contains("-") { return nil }
        isWest = true
        lonStr = lonStr.replacingOccurrences(of: "W", with: "")
    }
    if lonStr.contains("E") {
        if isWest { return nil }
        if lonStr.contains("-") { return nil }
        lonStr = lonStr.replacingOccurrences(of: "E", with: "")
    }
    guard let lont = Double(lonStr.trim) else {return nil}  // lon is not a number
    var lon = lont
    if isWest { lon = -lont }
    if lon < -180.0 || lon > 180.0      {return nil}  // Lon out-of bounds
    return lon
}

public func isLatLonValid(_ latLonTxt: String) -> Bool {
    let  tupleLL = decodeLL(latLonTxt: latLonTxt)
    if tupleLL.errorLL != ""            {return false}
    return true
}

public func decodeLL(latLonTxt: String) -> (lat: Double, lon: Double, errorLL: String ) {
    let LL = getFirstPart(latLonTxt)
    var sep = " "
    if LL.contains(",") {
        sep = ","
    } else if LL.contains(";") {
        sep = ";"
    } else {
        sep = " "
    }
    let splitLL = LL.components(separatedBy: sep)
    if splitLL.count != 2               { return (0.0, 0.0, "error: Lat/Lon must be separated.") }  // No comma or space separator
    let latTxt = splitLL[0].trim
    let lonTxt = splitLL[1].trim

    guard let lat = getLat(latTxt) else { return (0.0, 0.0, "error: Lat not valid") }  // Lat is not a number
    guard let lon = getLon(lonTxt) else { return (lat, 0.0, "error: Lon not valid") }  // Lon is not a number
    return (lat, lon, "")
}

// get the 1st part of a String, separated by 'separator' (default ":") trimmed
public func getFirstPart(_ text: String, separator: String = ":") -> String {
    if !text.contains(separator) { return text }
    let p = text.IndexOf(searchforStr: separator)
    return text.left(p).trim
}

