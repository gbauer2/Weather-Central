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

// Location Struct
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


/*  ----- URLSession with taskCallback -----
import UIKit
 
class ViewController: UIViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
 
        let URLString = "https://apple.com"
        let url = URL(string: URLString)
        let request = URLRequest(url: url!)
 
        ViewController.execTask(request: request) { (ok, obj) in
 
            print("I AM BACK")
    }
}
 

private class func execTask(request: URLRequest, taskCallback: @escaping (Bool, AnyObject?) -> ()) {
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    print("THIS LINE IS PRINTED")
    let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
        if let data = data {
            print("THIS ONE IS PRINTED, TOO")
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                taskCallback(true, json as AnyObject?)
            } else {
                taskCallback(false, json as AnyObject?)
            }
        }
    })
    task.resume()
}

*/
