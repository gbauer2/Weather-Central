//
//  APIKeyVC.swift
//  Weather Central
//
//  Created by George Bauer on 10/13/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import Foundation

// ???? change type to enum, add station,stationLL
struct Feature {
    let hasData:  Bool
    let date:     Date
    let type:     Int
    let place:    String
    var placeLat: Double
    var placeLon: Double
    let data:     [[String:AnyObject]]
    // Empty init sets hasData to false
    init() {
        hasData  = false
        date     = Date()
        type     = 0
        place    = ""
        placeLat = -999.0
        placeLon = -999.0
        data     = [[String:AnyObject]()]
    }
    // init(type, place, data) sets hasData to true, and sets date to Now
    init(type: Int, place:String, data: [[String:AnyObject]] ) {
        self.hasData  = true
        self.date     = Date()
        self.type     = type
        self.place    = place
        self.placeLat = -999
        self.placeLon = -999
        self.data     = data
    }
}

// Change to array or dictionary????
var gAlerts     = Feature()
var gAlmanac    = Feature()
var gAstronomy  = Feature()
var gConditions = Feature()
var gGeoLookup  = Feature()
var gHistory    = Feature()
var gHurricane  = Feature()
var gForecast   = Feature()
var gHourly     = Feature()
var gPlanner    = Feature()
var gTide       = Feature()

var wuAPI = WuAPI()

protocol WuAPIdelegate {
    func downloadDone(isOK: Bool, numFeaturesRequested: Int ,numFeaturesReceived: Int, errStr: String)    //delegate (1)
    // more optional or required methods if needed
}

class WuAPI {
    var delegate: WuAPIdelegate!          //delegate <— (2)


    //---------------------- downloadData func ---------------------
    public func downloadData(url: URL, place: String) {

        //------------------------------- task (thread) ------------------------------
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            var taskError = ""
            var numFeaturesRequested = 0
            var numFeaturesReceived  = 0

            let checkLog = tryToLogCall(makeCall: true)
            taskError = "Call limit! Try again " + checkLog.msg
            if !checkLog.isOK {
                self.delegate!.downloadDone(isOK: false, numFeaturesRequested: numFeaturesRequested, numFeaturesReceived: numFeaturesReceived, errStr: taskError) //delegate <— (3)
                return
            } 

            if let response = response {
                print ("\n-------- response --------\n\(response)\n------ end response ------\n")
            }
            guard error == nil, let dataReturned = data else {
                DispatchQueue.main.async {
                    print("\ndownloadData Err202: ",error as AnyObject)
                    //self.lblError.text = "Err202:\(error!)"
                    //UIApplication.shared.isNetworkActivityIndicatorVisible = false  // turn-off built-in activityIndicator
                    //self.activityIndicator.stopAnimating()                          // turn-off My activityIndicator
                    //self.lblDetail.text = error.debugDescription
                    taskError = error?.localizedDescription ?? "Unknown error 202"
                    print("😡202:taskError = \(taskError)")
                    self.delegate!.downloadDone(isOK: false, numFeaturesRequested: numFeaturesRequested, numFeaturesReceived: numFeaturesReceived, errStr: taskError) //delegate <— (3)
                }// DispatchQueue.main.async
                return
            } //end guard else

            print("----------------- Print data if short ------------------")
            print(String(describing: dataReturned))
            if let string = String(data: dataReturned, encoding: String.Encoding.utf8) {
                if string.count < 500 {
                    print(string) //JSONSerialization
                } else {
                    print("Over 500 chars, so seems OK.")
                }
            }
            print("-------------------- end Print data --------------------\n")
            print("----------------- 🙂 URLSession OK 🙂 ------------------\n")

            taskError = ""

            jsonTry: do {
                let jsonResult = try JSONSerialization.jsonObject(with: dataReturned, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                guard let dictJson = jsonResult as? [String: AnyObject] else {  //Try to convert jsonResult to Dictionary
                    taskError  = "Err203:Could not convert JSON to Dictionary"
                    print("\n\(taskError)")
                    break jsonTry
                }
                //globalDictJSON = dictJson
                printDictionary(dict: dictJson, expandLevels: 0, dashLen: 0, title: "JSON")
                //self.printDictionary(dict: dictJson, expandLevels: 1, dashLen: 0, title: "JSON")

                guard let dictResponse =   dictJson["response"] as? [String: AnyObject] else { //Try to convert jsonResult["response"] to Dictionary
                    taskError = "Err204:No 'response' in JSON data"
                    print("\n\(taskError)")
                    break jsonTry
                }

                printDictionary(dict: dictResponse, expandLevels: 0, dashLen: 0, title: "Response")

                guard let dictFeatures = dictResponse["features"] as? [String: AnyObject] else { //Try to convert jsonResult.response.features to Dictionary
                    taskError = "Err205:No 'features' in JSON 'response' data"
                    print("\n\(taskError)")
                    break jsonTry
                }
                numFeaturesRequested = dictFeatures.count

                errorTry: do {      //See if there is an "error" entry in jsonResult.response
                    guard let dictError = dictResponse["error"] as? [String: AnyObject] else {taskError = "";  break errorTry}
                    printDictionary(dict: dictError, expandLevels: 1, dashLen: 0, title: "response.error")
                    taskError = "Err210:unknown error"
                    if let errType = dictError["type"]        as? String { taskError = errType }
                    if let errDesc = dictError["description"] as? String { taskError = errDesc }
                    print("\n\("Err210:" + taskError)")
                    break jsonTry
                }// end errorTry

                resultsTry: do {    //See if there is a "results" entry in jsonResult.response (suggests other wx stations)
                    guard let oResults = dictResponse["results"] else {taskError = "";  break resultsTry}
                    taskError = "Place not found."
                    print("\n\(taskError)")
                    print("-------- Results (suggested weather stations) -------")
                    print(oResults)
                    print("-----------------------------------------------------")
                    guard let resultsArr = oResults as? [[String: AnyObject]] else {
                        //printDictionary(dict: dictResults, expandLevels: 1, dashLen: 0, title: "Results")  //(oResults)
                        break jsonTry
                    }
                    guard let dictResults0 = resultsArr.first else {
                        print("Results Decode failed!");break jsonTry}
                    printDictionary(dict: dictResults0, expandLevels: 0, dashLen: 0, title: "Results[0]")
                    break jsonTry

                }//end resultsTry

                // Success! We made it! We got to Wunderground.com, sent our features, and got back a legitimate reply.
                printDictionary(dict: dictFeatures, expandLevels: 0, dashLen: 0, title: "response/features")

                if let alertsArr     = jsonResult["alerts"]     as? [[String: AnyObject]] {
                    numFeaturesReceived += 1
                    gAlerts = Feature(type: iAlerts, place: place, data: alertsArr)
                }

                if let dictAlmanac   = jsonResult["almanac"]    as? [String: AnyObject] {
                    numFeaturesReceived += 1
                    let almanacArr = [dictAlmanac]
                    gAlmanac = Feature(type: iAlmanac, place: place, data: almanacArr)
                }// "almanac"}

                if let dictMoonPhase = jsonResult["moon_phase"] as? [String: AnyObject] {
                    numFeaturesReceived += 1
                    let astroArr = [dictMoonPhase]
                    gAstronomy = Feature(type: iAstronomy, place: place, data: astroArr)
                }// "moon_phase"

                if let dictCurrentObservation = jsonResult["current_observation"] as? [String: AnyObject] {
                    numFeaturesReceived += 1
                    let conditionsArr = [dictCurrentObservation]
                    gConditions = Feature(type: iConditions, place: place, data: conditionsArr)
                }// "conditions"

                if let dictLocation  = jsonResult["location"]   as? [String: AnyObject] {
                    numFeaturesReceived += 1
                    let geoArr = [dictLocation]
                    gGeoLookup = Feature(type: iGeolookup, place: place, data: geoArr)
                    print(gGeoLookup.hasData)
                }//geoLookup

                if let dictHistory   = jsonResult["history"]    as? [String: AnyObject] {
                    numFeaturesReceived += 1
                    let histArr = [dictHistory]
                    gHistory = Feature(type: iHistory, place: place, data: histArr)
                }// "history"

                if let hurricaneArr  = jsonResult["currenthurricane"] as? [[String: AnyObject]] {
                    numFeaturesReceived += 1
                    gHurricane = Feature(type: iHurricane, place: place, data: hurricaneArr)
                }// "CurrentHurricane"

                if let dictForecast  = jsonResult["forecast"]   as? [String: AnyObject] {
                    numFeaturesReceived += 1
                    let forecastArr = [dictForecast]
                    gForecast = Feature(type: iForecast, place: place, data: forecastArr)
                }// "Forecast!"

                if let dictHourlyArr = jsonResult["hourly_forecast"] as? [[String: AnyObject]] {
                    numFeaturesReceived += 1
                    gHourly = Feature(type: iHourly, place: place, data: dictHourlyArr)
                }

                if let dictTrip      = jsonResult["trip"]       as? [String: AnyObject] {
                    numFeaturesReceived += 1
                    let tripArr = [dictTrip]
                    gPlanner = Feature(type: iPlanner, place: place, data: tripArr)
                }// "planner"

                if let dictTide      = jsonResult["tide"]       as? [String: AnyObject] {
                    numFeaturesReceived += 1
                    let tideArr = [dictTide]
                    gTide = Feature(type: iTide, place: place, data: tideArr)
                }// "tide"

            } catch { //jsonTry:do Try/Catch -  (try JSONSerialization.jsonObject) = failed
                taskError = "Err208: Can't get JSON data!"
                print("\n\(taskError)")
            }//end jsonTry:do Try/Catch

            // Success again! We have made it through everything.

            DispatchQueue.main.async {
                let isOK = taskError.isEmpty
                let es = isOK ? "" : "dwnld Error = \(taskError)"
                print("End of task:  isOK = \(isOK)   \(es)")
                self.delegate!.downloadDone(isOK: isOK, numFeaturesRequested: numFeaturesRequested, numFeaturesReceived: numFeaturesReceived, errStr: taskError) //delegate <— (3)

                //————— Permanent Storage —————-
                if taskError == "" {

                } else {
                    //self.showAlert(title: "Fail", message: "Tryed API Key: \(self.APItxt)\n\(taskError)")
                }

            }// DispatchQueue.main.async

        } //----------------------------- end task (thread) -----------------------------------

        //self.activityIndicator.startAnimating()
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true

        task.resume()
        return
    }//end func downloadData
}//end class


/*
// Stuff needed in Calling ViewController

 // Stored properties
 var WuDownloadDone = false
 let wuURLstr = "https://api.wunderground.com/api/1333bd5d27bb2c1b/hourly10day/q/zip:_34786.json"
 var wuURL : URL?
 
 extension ViewController: WuAPIdelegate {      //delegate <— (4)

    //This function is called your download request
        func startWuDownload(wuURL: URL) {
        WuDownloadDone = false
        lblWuDownload.text = "...downloading"       // change this label, start activityIndicators
        //wuURL = URL(string: wuURLstr)!
        wuAPI.delegate = self                   //delegate <— (5)
        let str = wuAPI.downloadData(url: wuURL!)
        print(str)
    }

    func downloadDone(isOK: Bool, numFeaturesRequested: Int,  numFeaturesReceived: Int, errStr: String){    //delegate (6)
        DispatchQueue.main.async {
            print("ViewController downloadDone delegate reached:")
            let es = isOK ? "" : "\(errStr)\n"
            let msg = "isOK = \(isOK)\n\(es)\(numFeaturesRequested) features requested, \(numFeaturesReceived) received."
            print(msg)
            self.lblWuDownload.text = msg           // change this label, stop activityIndicators
            //process your data
        }
    }
 }

 */
