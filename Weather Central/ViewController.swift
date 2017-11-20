//
//  ViewController.swift
//  Weather Central
//
//  Created by George Bauer on 8/9/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

//TODO: - ToDo list
/*
 1) Redo Home page to allow either NearMe or LastUsed or GeoLookup.
    a. Allow GeoLookup to save location without picking WxStation
 2) If NO Features selected, Default to "Almanac, Astronomy, Conditions"
 3) Select Hours & Days of interest for "Hourly" (e.g. Wed,Thu,Fri 8AM-2PM)
 4) Settings:(Default NSEW hemi)(LatLon display)(mi,nm,km)(degC,degF)(AMPM,24hr)(call limits)(WU level)
             Test new API Key before accepting it.
 5) Hurricane forecast & map
 6) Map: DistDir in info, dotted line to selected, icon for airports, Show previously found stations
 7) Customize for landscape, or 6 vs 6+ in portait
 8) Bigger Font for 6sPlus & iPad - Forecast, Hourly
 9) Show Version on main Settings screen
 
 Issues:
    Alerts: if just 1 Alert, put its name in heading
    Current: 6s wraps wind, precip(1-hr)
    Tropics: Shows 2 Storms when there is only 1
    Hourly: wraps for long Wx (Few Showers/Wind)(Partly Cloudy/Wind)(Chance of a Thunderstorm)

New Features to be added later.
 1) Route planning for next 5 days.
 2) Airport database
 3) Save downloads for later analysis
 4) Save Stations found for future use in Map

1.0.5 Select Wx Station on map
 Select Lat/Lon with LongPress on Map
 Large Activity Indicator for geoLookup
 
Get some stuff with every query *Almanac&Astron= 1K,
                                 GeoLookup     = 8k,
                                *Conditions    = 3k
                                 Forecast      = 8k     10day (+)=19k,
                                 AutoComplete*? no key
                                                                                    Hurricanes(++)=31k(2),
                                                        Hourly(+)=47k               10day     (++)=310k,
                                                                                    Planner   (++)=4K, Yesterday(++)=10k History(?)=12k,
                                                        Tide  (+)=15k,RawTide(+)=60k
                                     Sat=1k,  webcams = 11k
 */

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    //let allowedFeatures = ["alerts", "almanac", "astronomy", "conditions", "currenthurricane", "forecast", "forecast10day", "geolookup", "history", "hourly", "hourly10day", "planner", "rawtide", "satellite", "tide", "webcams", "yesterday"]

    //MARK: ---- ViewController Variables ----
    let APIKEY = ""    //let APIKEY = "1333bd..."
    var numFeatures = 0
    var featuresStr = ""
    var prevCityLen = 999
    var cityLockLen = -1
    var locationManager = CLLocationManager()
    var userLocation    = CLLocation(latitude: 0.0, longitude: 0.0)
    var rawFontDefault  = UIFont(name: "Menlo", size: 12)

    //MARK: ---- IBOutlets ----
    @IBOutlet weak var btnAlerts:     UIButton!
    @IBOutlet weak var btnAlmanac:    UIButton!
    @IBOutlet weak var btnConditions: UIButton!
    @IBOutlet weak var btnHurricane:  UIButton!
    @IBOutlet weak var btnForecast:   UIButton!
    @IBOutlet weak var btnHourly:     UIButton!
    @IBOutlet weak var btnPlanner:    UIButton!
    @IBOutlet weak var btnTide:       UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblRawDataHeading: UILabel!
    @IBOutlet weak var lblError:          UILabel!
    @IBOutlet weak var txtState:      UITextField!
    @IBOutlet weak var txtCity:       UITextField!
    @IBOutlet weak var txtStationID:  UITextField!
    @IBOutlet weak var txtRawData:     UITextView!

    //MARK: ---- iOS built-in functions & overrides ----
    override func viewDidLoad() {
        super.viewDidLoad()
        rawFontDefault = txtRawData.font
        CallLogInit()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        gAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        gAppBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        self.activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2) // Make my activityIndicator bigger

    }//end func
   
    override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let ver = Device.TheCurrentDeviceVersion
        let orientation = UIDevice.current.orientation.isLandscape ? "Landscape" : "Portrait"
        let devName = UIDevice.current.name
        let devSystem = UIDevice.current.systemName
        //let d = UIDevice.current.batteryLevel
        //print(d)
        print("😁 W=\(Int(screenWidth)), H=\(Int(screenHeight)), \(Device.PHONE_OR_PAD) in \(orientation), \(devName), \(devSystem) \(ver) 😁\n")

        gUpdateGeoLookup = true
        var nameObject = UserDefaults.standard.object(forKey: "wuapikey")
            if let name = nameObject as? String {
            print(name)
            gAPIKey = name
        } else {
            print("UserDefaults.standard.object(forKey: \"wuapikey\") NOT Found.")
        } //end if let name
        
        gCity = UserDefaults.standard.object(forKey: "wucity") as? String ?? ""
        txtCity.text = gCity
        
        gState = UserDefaults.standard.object(forKey: "wustate") as? String ?? ""
        txtState.text = gState
        
        gStationID = UserDefaults.standard.object(forKey: "wuStationID") as? String ?? ""
        txtStationID.text = gStationID
        
        nameObject = UserDefaults.standard.object(forKey: "wuFeaturesArray")
        if let temp = nameObject as? [Bool] {
            //print("wuFeaturesArray = \(temp)")
            wuFeaturesArr = temp
        } else {
            print("UserDefaults.standard.object(forKey: \"wuFeaturesArray\") NOT Found.")
            
        } //end if let name
        
        
        nameObject = UserDefaults.standard.object(forKey: "wuFeatures")
        if let name = nameObject as? String {
            print(name)
            featuresStr = name
        } else {
            print("UserDefaults.standard.object(forKey: \"wuFeatures\") NOT Found.")
            featuresStr = "geolookup/"
        } //end if let name
        
        txtRawData.text = ""
        lblError.textAlignment = NSTextAlignment.center
        lblError.text = "----"
        
        // Set Buttons according to wuFeaturesArr[]
        setFeatureButtons()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.activityIndicator.stopAnimating()                  // make sure activityIndicator is off
        //UIApplication.shared.endIgnoringInteractionEvents()   // if you were ignoring events
        numFeatures = 0
        for isSelected in wuFeaturesArr {
            if isSelected {numFeatures += 1}
        }
        if wuFeaturesArr[iAstronomy] { numFeatures -= 1 }
        clearRawData()
        if gAPIKey.count < 15 {
        showAlert(title: "Important!", message: "You must obtain an 'API Key' from wunderground.com to use this app.  Tap ⚙️, type in key, and tap 'update'.")
        }
    }//end func viewDidAppear

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //————— Permanent Storage —————-
        UserDefaults.standard.set(txtCity.text, forKey: "wucity")
        gCity = txtCity.text!
        UserDefaults.standard.set(txtState.text, forKey: "wustate")
        gState = txtState.text!
        UserDefaults.standard.set(txtStationID.text, forKey: "wuStationID")
        gStationID = txtStationID.text!
        
        print("Saved \(txtStationID.text!)  \(txtCity.text!), \(txtState.text!)")
    }
    
    // when you get location from CLLocationManager, record gUserLat & gUserLon, and stop updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[0])
        userLocation = locations[0]
        gUserLat = userLocation.coordinate.latitude
        gUserLon = userLocation.coordinate.longitude
        print("\n** locationManager",gUserLat,gUserLon,"**\n")
        locationManager.stopUpdatingLocation()
    }

    // ------ Dismiss Keybooard if user taps empty area ------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // ------ Dismiss Keybooard if user taps "Return" ------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("\ntextFieldShouldReturn called by:")
        print(textField)
        print("\n")
        return true
    }
    
    //MARK: ---- IBActions ----
    @IBAction func btnAlertsPress(_ sender: Any) {
        self.view.endEditing(true)
        lblError.text = DoAlerts(jsonResult: globalDictJSON)
    }
    @IBAction func btnAlmanacPress(_ sender: Any) {
        self.view.endEditing(true)
        lblError.text = DoAlmanac(jsonResult: globalDictJSON)
        lblError.text = DoAstronomy(jsonResult: globalDictJSON)
    }
    @IBAction func btnConditionsPress(_ sender: Any) {
        self.view.endEditing(true)
        lblError.text = DoCurrentObservation(jsonResult: globalDictJSON)
    }
    @IBAction func btnHurricanePress(_ sender: Any) {
        self.view.endEditing(true)
        lblError.text = DoHurricane(jsonResult: globalDictJSON)
    }
    @IBAction func btnForecastPress(_ sender: Any) {
        self.view.endEditing(true)
        lblError.text = DoForecast(jsonResult: globalDictJSON)
    }
    @IBAction func btnHourlyPress(_ sender: Any) {
        self.view.endEditing(true)
        lblError.text = DoHourly(jsonResult: globalDictJSON)
    }
    @IBAction func btnPlannerPress(_ sender: Any) {
        self.view.endEditing(true)
        if wuFeaturesArr[iPlanner] {
            let temp = DoPlanner(jsonResult: globalDictJSON)
            lblError.text = temp
        } else {
            lblError.text = DoHistory(jsonResult: globalDictJSON)
        }
    }
    @IBAction func btnTidePress(_ sender: Any) {
        self.view.endEditing(true)
        lblError.text = DoTide(jsonResult: globalDictJSON)
    }

    //MARK: Move this to GeoLookup =====================

    let cityAbrev = ["Fred": "Fredericksburg,PA", "Har": "Harrisburg,PA",
                     "My":   "Myrtle Beach,SC",   "Tru": "Trumbull,CT",
                     "Red":  "Redding,CT",        "Oco": "Ocoee,FL",
                     "Brid": "Bridgeport,CT",    "Danb": "Danbury,CT",
                     "Wolc": "Wolcott,CT",       "Wolf": "Wolfeboro,ME",
                     "Wind": "Windermere,FL",     "Jac": "Jacksonville,FL",
                    ]
    
    //-------------------- City - Editing Change ----------
    @IBAction func txtCityEditChange(_ sender: Any) {
        if gDataIsCurrent {
            gDataIsCurrent = false
            setFeatureButtons()
        }
        let citytxt = txtCity.text!     // text after change
        let cnt     = citytxt.count     // number of chars now
        let prev    = prevCityLen       // previous number of chars
        prevCityLen = cnt               // udate prevCityLen to now
        if cnt - prev != 1 {            // if user did not just add a char
            cityLockLen = 99            // disable length limit
            return                      // and accept the edit
        }
        if cnt > cityLockLen {          // if adding char would exceed length limit
            txtCity.text = citytxt.left(cityLockLen)
            prevCityLen = cityLockLen
        }
        guard let combName = cityAbrev[citytxt] else { return } // dictionary lookup of stored "City,States"
        // If a match is found in the cityAbrev dictionary, do the following
        let splitNames = combName.components(separatedBy: ",")  // separate city & state
        cityLockLen   = splitNames[0].count                     // stop user from adding more chars
        prevCityLen   = cityLockLen                             // update prevCityLen
        txtCity.text  = splitNames[0]                           // set the text fields to stored values
        txtState.text = splitNames[1]

    }//end @IBAction func txtCityEditChange

//=========================================================

    //-------------------- GetData Button -------------------
    @IBAction func btnGetData(_ sender: Any) {
        self.view.endEditing(true)
        txtRawData.text = ""
        lblError.text   = ""
        
        if txtCity.text!.count < 3 {
            showError("You must enter a proper city name.")
            return
        }
        
        if txtState.text!.count != 2 && txtState.text != "" {
            showError("You must enter blank or 2-letter state code.")
            return
        }
        
        if numFeatures == 0 {
            showError("You must select at least 1 feature.")
            return
        }
        gCity = txtCity.text!
        gState = txtState.text!
        gStationID = txtStationID.text!
        var place = gState + "/" + gCity
        if gStationID.count >= 3 {
            if gStationID.count <= 4 {
                place = gStationID
            } else {
                place = "pws:" + gStationID
            }
        }
        let urlTuple = makeWuUrlJson(APIKey: gAPIKey, features: featuresStr, place: place)
        if urlTuple.errorStr != "" {
            showError(urlTuple.errorStr)
            return
        }

        let url = urlTuple.url
        weatherJSON(url: url)   //
        clearRawData()
    }//end @IBAction func btnGetData
    
// MARK: ---- My Functions ----

    // Clear txtRawData(font to default). Set lblRawDataHeading to 18pt, adjust to width, "# Features Selected"
    func clearRawData() {
        lblRawDataHeading.adjustsFontSizeToFitWidth = true
        lblRawDataHeading.font = UIFont(name: lblRawDataHeading.font.fontName, size: 18)
        lblRawDataHeading.textAlignment = NSTextAlignment.center
        lblRawDataHeading.text = showCount(count: numFeatures, name: "Feature" , ifZero: "No") + " Selected"    //"\(numFeatures) features Selected"
        txtRawData.text = ""
        txtRawData.font = rawFontDefault
    }
    // ------ Enable/Disable a Button and change its backgroundColor between  colorButtonNorm & colorButtonGray ------
    func enableButton(btn: UIButton, enable: Bool) {
        btn.isEnabled = enable                                              // enable/disable
        btn.backgroundColor = enable ? colorButtonNorm : colorButtonGray    //blue=(0x007AFF) or gray
    }

    // ------ Set Buttons according to wuFeaturesArr[] ------
    func setFeatureButtons() {
        for iButton in 1..<18 {
            var isOn = wuFeaturesArr[iButton]

            switch iButton {
            case iForecast:
                isOn = wuFeaturesArr[iButton] || wuFeaturesArr[iForecast10day]
            case iHourly:
                isOn = wuFeaturesArr[iButton] || wuFeaturesArr[iHourly10Day]
            case iPlanner:  //, iYesterday: //12
                isOn = wuFeaturesArr[iButton] || wuFeaturesArr[iHistory] || wuFeaturesArr[iYesterday]//9 or 17
                if wuFeaturesArr[iButton] {btnPlanner.setTitle("Planner", for: UIControlState.normal)}
            case iHistory:
                if wuFeaturesArr[iButton] {btnPlanner.setTitle("Today", for: UIControlState.normal)}
            case iYesterday:
                if wuFeaturesArr[iButton] {btnPlanner.setTitle("Yesterday", for: UIControlState.normal)}
            default:
                isOn = wuFeaturesArr[iButton]
            }//end switch

            if let button = view.viewWithTag(iButton) as? UIButton {
                enableButton(btn: button, enable: gDataIsCurrent)
                //button.isEnabled = gDataIsCurrent                               // Only enable Buttons after a download
                //button.backgroundColor = gDataIsCurrent ? colorButtonNorm : colorButtonGray   //blue=(0x007AFF)
                button.isHidden = !isOn            // Hide Buttons not in wuFeatures list.

                //print("Feature#\(iButton), button[\(iButton)] = \(wuFeaturesArr[button.tag])")
            }//endif
        }//next iButton
    }

    func showError(_ message: String) {
        showAlert(title: "Error", message: message)
    }
    
    func showAlert(title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func getJsonFromFile() {
        guard let path = Bundle.main.path(forResource: "someJson", ofType: "txt") else {return}
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            print(json)
        } catch {
            print(error)
        }
    }
    
    //MARK: ------------------ weatherJSON func -----------------
    func weatherJSON(url: URL) {
        
        let checkLog = tryToLogCall(makeCall: true)
        if !checkLog.isOK { return }

        //------------------------------- task (thread) ------------------------------
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in  //(with: request as URLRequest)
            guard error == nil, let urlContent = data else {
                DispatchQueue.main.async {
                    self.lblError.text = "\(error!)"
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.activityIndicator.stopAnimating()
                    print("Err03: ",error as Any)
                    self.txtRawData.text = error.debugDescription           //??
                }// DispatchQueue.main.async
                return
            } //end guard
            
            print("🙂 URLSession OK")
            
            print("GWB: ------------------ Print dataString -------------------")
            print(String(describing: urlContent))
            if  let string = String(data: data!, encoding: String.Encoding.utf8) {
                if string.count < 1000 {
                    print(string) //JSONSerialization
                }
            }
            print("GWB: ------------------ URLSession  done -------------------")
            
            var myError = ""
            
            jsonTry: do {
                let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject

/*
                print("========================== JSON Data ===========================")
                print(jsonResult)
                print("========================== End  JSON ===========================")
                print()
*/
                guard let dictJson = jsonResult as? NSDictionary else {                 //Try to convert jsonResult to Dictionary
                    myError  = "Could not convert JSON to Dictionary"; break jsonTry
                }
                globalDictJSON = dictJson
                printDictionaryNS(dictNS: dictJson, expandLevels: 0, dashLen: 0, title: "JSON")
                //self.printDictionaryNS(dictNS: dictJson, expandLevels: 1, dashLen: 0, title: "JSON")
/*
========================== JSON Data ===========================
{
    response =     {
        error =         {
            description = "No cities match your search query";
            type = querynotfound;
        };
        features =         {
            astronomy = 1;
            geolookup = 1;
        };
        termsofService = "http://www.wunderground.com/weather/api/d/terms.html";
        version = "0.1";
    };
}
========================== End  JSON ===========================
*/
                guard let dictResponse =   dictJson["response"] as? [String: AnyObject] else { //Try to convert jsonResult["response"] to Dictionary
                    myError = "No 'response' in JSON data"; break jsonTry
                }
                guard let dictFeatures = dictResponse["features"] as? [String: AnyObject] else { //Try to convert jsonResult.response.features to Dictionary
                    myError = "No 'features' in JSON 'response' data";  break jsonTry}
                
                errorTry: do {                              //See if there is an "error" entry in jsonResult.response
                    guard let dictError = dictResponse["error"] as? [String: AnyObject] else {myError = "";  break errorTry}
                    myError = "Err210:unknown error"
                    if let err = dictError["type"] as? String { myError = err }
                    if let er = dictError["description"] as? String { myError = er }
                    print("\n\("Err210:" + myError)")
                    break jsonTry
                }// end errorTry
                
                resultsTry: do {                            //See if there is a "results" entry in jsonResult.response (suggests cities in other states)
                    guard let oResults = dictResponse["results"] else {myError = "";  break resultsTry}
                        print("\(gCity) not found in \(gState)\n")
                        print(oResults)
                        myError = "\(gCity) not found in \(gState)"
                        break jsonTry
                }//end resultsTry
                
                // Success! We made it! We got to Wunderground.com, sent our features, and got back a legitimate reply.
                
                printDictionary(dict: dictFeatures, expandLevels: 0, dashLen: 0, title: "response/features")
                
                wuFeaturesWithDataArr = wuFeaturesArr
                
            } catch { //jsonTry:do Try/Catch -  (try JSONSerialization.jsonObject) = failed
                print("Uh oh. You have an error with \(gCity), \(gState)!")
                myError = "Err03: Can't get \(self.featuresStr) in \(gCity), \(gState)!"
            }//end jsonTry:do Try/Catch
            
            // Success again! We have made it through everything,so save stuff for next time.
            DispatchQueue.main.async {
                self.lblError.text = myError
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityIndicator.stopAnimating()
                if myError == "" {
                    gDataIsCurrent = true
                    self.setFeatureButtons()
                    //————— Permanent Storage —————-
                    UserDefaults.standard.set(gCity, forKey: "wucity")
                    UserDefaults.standard.set(gState, forKey: "wustate")
                    UserDefaults.standard.set(self.featuresStr, forKey: "wuFeatures")
                    if self.numFeatures == 1  {
                        var singleItem = 0
                        for i in 1..<wuFeaturesArr.count {
                            if wuFeaturesArr[i] {
                                singleItem = i
                                break
                            }//endif
                        }//next i

                        switch singleItem {
                        case iAlerts:
                            self.lblError.text = self.DoAlerts(jsonResult: globalDictJSON)
                        case iAlmanac:
                            self.lblError.text = self.DoAlmanac(jsonResult: globalDictJSON)
                            self.lblError.text = self.DoAstronomy(jsonResult: globalDictJSON)
                        case iConditions:
                            self.lblError.text = self.DoCurrentObservation(jsonResult: globalDictJSON)
                        case iGeolookup:
                            self.lblError.text = self.DoGeolookup(jsonResult: globalDictJSON)
                        case iHistory, iYesterday:
                            self.lblError.text = self.DoHistory(jsonResult: globalDictJSON)
                        case iHurricane:
                            self.lblError.text = self.DoHurricane(jsonResult: globalDictJSON)
                        case iForecast, iForecast10day:
                            self.lblError.text = self.DoForecast(jsonResult: globalDictJSON)
                        case iHourly, iHourly10Day:
                            self.lblError.text = self.DoHourly(jsonResult: globalDictJSON)
                        case iPlanner:
                            self.lblError.text = self.DoPlanner(jsonResult: globalDictJSON)
                        case iTide:
                            self.lblError.text = self.DoTide(jsonResult: globalDictJSON)
                        default:
                            self.lblError.text = "Could not identify Feature#\(singleItem)"
                        }
 
                    }
                }
            }// DispatchQueue.main.async
            
        } //----------------------------- end task (thread) -----------------------------------
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.activityIndicator.startAnimating()
        task.resume()
        //print ("====================== AFTER TASK =======================")
        return
    }//end func weatherJSON

    
    //=========================================================================================
  
    //MARK: ---- Do each of the selected Featuees ----
    //--------------------------- DoAlerts ------------------------
    func DoAlerts(jsonResult: AnyObject) -> String {
        clearRawData()
        //let myError = ""
        guard let alertsArr = jsonResult["alerts"] as? [[String: AnyObject]] else {return "\"alerts\" not in downloaded data!!"}
        
        let countTxt = showCount(count: alertsArr.count, name: "Alert", ifZero: "No")
        print(countTxt)
        lblRawDataHeading.textAlignment = NSTextAlignment.center
        lblRawDataHeading.text = countTxt
        if alertsArr.count == 0 {return ""}

        printDictionary(dict: alertsArr[0], expandLevels: 0, dashLen: 16, title: "Alerts[0]")
        printDictionary(dict: alertsArr[0], expandLevels: 1, dashLen: 16, title: "Alerts[0]")
        
        var aa = ""
        for dictAlert in alertsArr {
            let desc = dictAlert["description"] as? String ?? "- no description -"
            let message =  dictAlert["message"] as? String ?? "- no message -"
            aa += desc + "\n" + message
        }
        txtRawData.text = aa
        print("Alerts Done")
        return ""
        
        /*
         description
         date_epoch
         ZONES()
         message
         phenomena
         significance
         expires
         StormBased{}
         type
         tz_long
         date
         expires_epoch
         tz_short
         
         */
    }//end func DoAlerts
    
    //--------------------------- DoAlmanac ------------------------
    func DoAlmanac(jsonResult: AnyObject) -> String {
        clearRawData()
        txtRawData.font = UIFont(name: rawFontDefault!.fontName, size: 17)

        guard let dictAlmanac = jsonResult["almanac"] as? [String: AnyObject] else {return "\"almanac\" not in downloaded data!"}
        
        var a1 = ""
        
        printDictionary(dict: dictAlmanac, expandLevels: 0, dashLen: 14, title: "Almanac")
        printDictionary(dict: dictAlmanac, expandLevels: 1, dashLen: 14, title: "Almanac")
        
        let apt = dictAlmanac["airport_code"] as? String ?? "?"
        lblRawDataHeading.text = "Almanac for \(apt)"
        
        guard let dictTempLow = dictAlmanac["temp_low"] as? [String: AnyObject] else {return "\"almanac/temp_low\" not in downloaded data!"}
        
        let dictLowNormal = dictTempLow["normal"] as! [String: AnyObject]
        let strLowNormF = dictLowNormal["F"] as? String ?? "?"
        let dictLowRecord = dictTempLow["record"] as! [String: AnyObject]
        let strLowRecF = dictLowRecord["F"] as? String ?? "?"
        let yrLow = dictTempLow["recordyear"] as? String ?? "?"
        guard let dictTempHigh = dictAlmanac["temp_high"] as? [String: AnyObject] else {return "\"almanac/temp_high\" not in downloaded data!"}
        
        let dictHighNormal = dictTempHigh["normal"] as! [String: AnyObject]
        let strHighNormF = dictHighNormal["F"] as! String
        let dictHighRecord = dictTempHigh["record"] as! [String: AnyObject]
        let strHighRecF = dictHighRecord["F"] as! String
        let yrHigh = dictTempHigh["recordyear"] as? String ?? "?"
        
        a1 += "      Normal     Record\n"
        a1 += "Low     \( strLowNormF)°      \( strLowRecF)° \(yrLow)\n"
        a1 += "High    \(strHighNormF)°      \(strHighRecF)° \(yrHigh)\n"
        
        txtRawData.text =  a1 + "\n"
        
        return ""
/*
========================== Almanac ===========================
airport_code --> KCRE
temp_low --> {
    normal = { C = 21; F = 70; };
    record = { C = 12; F = 55; };
    recordyear = 1954;
    }
temp_high --> {
    normal =  { C = 30; F = 86; };
    record =  { C = 35; F = 95; };
    recordyear = 2010;
    }
======================== end Almanac =========================
*/
    }//end func DoAlmanac
    
    //---------------------------------- DoAstronomy ------------------------------------
    func DoAstronomy(jsonResult: AnyObject) -> String {
        //clearRawData()
        guard let dictMoonPhase = jsonResult["moon_phase"] as? [String: AnyObject] else {return "\"moon_phase\" not in downloaded data!"}
        
        printDictionary(dict: dictMoonPhase, expandLevels: 0, dashLen: 21, title: "MoonPhase")
        printDictionary(dict: dictMoonPhase, expandLevels: 1, dashLen: 21, title: "MoonPhase")
        
        var aa = ""
        
        let dictSunrise = dictMoonPhase["sunrise"] as! [String: AnyObject]
        let srHr = dictSunrise["hour"] as! String
        let srMin = dictSunrise["minute"] as! String
        
        let dictSunset = dictMoonPhase["sunset"] as! [String: AnyObject]
        let ssHr = dictSunset["hour"] as! String
        let ssMin = dictSunset["minute"] as! String
        
        aa += "Sunrise  \(srHr):\(srMin)   Sunset  \(ssHr):\(ssMin)\n"
        
        aa += "\n"
        
        let dictMoonrise = dictMoonPhase["moonrise"] as! [String: AnyObject]
        let mrHr = dictMoonrise["hour"] as! String
        let mrMin = dictMoonrise["minute"] as! String
        
        let dictMoonset = dictMoonPhase["moonset"] as! [String: AnyObject]
        let msHr = dictMoonset["hour"] as! String
        let msMin = dictMoonset["minute"] as! String

        aa += "Moonrise \(mrHr):\(mrMin)  Moonset  \(msHr):\(msMin)\n"
        
        let ageOfMoon  = dictMoonPhase["ageOfMoon"]!
        let percentIlluminated   = dictMoonPhase["percentIlluminated"]!
        let phaseofMoon   = dictMoonPhase["phaseofMoon"]!

        aa += "\(ageOfMoon) days  \(percentIlluminated)% Illuminated\n  \(phaseofMoon)\n"
        
        let a1 = txtRawData.text
        txtRawData.text = "\n" + a1! + "\n" + aa

        return ""
/*
         ========================== MoonPhase base ===========================
         hemisphere ----> North
         current_time --> {Dictionary} with 2 items
         sunrise -------> {Dictionary} with 2 items
         sunset --------> {Dictionary} with 2 items
         moonrise ------> {Dictionary} with 2 items
         moonset -------> {Dictionary} with 2 items
         ageOfMoon -----> 6
         phaseofMoon ---> Waxing Crescent
         percentIlluminated -> 31
         ======================== end MoonPhase base =========================
         
         ========================== MoonPhase expanded ===========================
         hemisphere ----> North
         current_time --> { hour = 22; minute = 46; }
         sunrise -------> { hour =  7; minute = 05; }
         sunset --------> { hour = 19; minute = 07; }
         moonrise ------> { hour = 12; minute = 03; }
         moonset -------> { hour = 22; minute = 49; }
         ageOfMoon -----> 6
         phaseofMoon ---> Waxing Crescent
         percentIlluminated --> 31
         ======================== end MoonPhase expanded =========================
*/
        }//end func DoAstronomy

    // ------------------------------- Do current_observation ---------------------------
    func DoCurrentObservation(jsonResult: AnyObject) -> String {
        clearRawData()
        txtRawData.font = UIFont(name: rawFontDefault!.fontName, size: 16)
        let myError = ""
        
        guard let dictCurrentObservation = jsonResult["current_observation"] as? [String: AnyObject] else {return "\"conditions\" not in downloaded data!"}
        
        printDictionary(dict: dictCurrentObservation, expandLevels: 0, dashLen: 25, title: "current_observation")
        printDictionary(dict: dictCurrentObservation, expandLevels: 1, dashLen: 25, title: "current_observation")

        let dictDisplayLocation = dictCurrentObservation["display_location"] as! [String: AnyObject]
        let dictObservationLocation = dictCurrentObservation["observation_location"] as! [String: AnyObject]
        
        printDictionary(dict: dictDisplayLocation,     expandLevels: 0, dashLen: 17, title: "display_location")
        printDictionary(dict: dictObservationLocation, expandLevels: 0, dashLen: 17, title: "observation_location")

        var aa = ""
        
        let displayLocation = Location(loc: dictDisplayLocation)                //Convert dictionary to Location type
        print("\n---- displayLocation ----\n\(displayLocation)\n")
        var observationLocation = Location(loc: dictObservationLocation)
        print("\n---- observationLocation ----\n\(observationLocation)\n")
        
        if observationLocation.lat == "" || observationLocation.lon == "" {
            observationLocation = displayLocation
            print("\n---- observationLocation ----\n\(observationLocation)\n")
        }
        
        let dfull = displayLocation.full
        let dzip  = displayLocation.zip

        let full  = observationLocation.full
        let lat   = Double(observationLocation.lat) ?? 0.0
        let lon   = Double(observationLocation.lon) ?? 0.0
        let elev  = observationLocation.elevation
        
        aa = "\(dfull) \(dzip)\n\(full)\n\(formatLatLon(lat: lat, lon: lon, places: 3)) elev: \(elev)"
        aa += "\n--------------------------------\n"

        let titleLen = 17

        let station_id = dictCurrentObservation["station_id"] as? String ?? "?"
        aa += formatDictionaryStr(title: "station_id", str: station_id, titleLen: titleLen) + "\n"
        
        //--------
        let observation_time_rfc822 = dictCurrentObservation["observation_time_rfc822"] as? String ?? "?"
        let splitNames = observation_time_rfc822.components(separatedBy: ":")
        var observationTime = observation_time_rfc822
        if splitNames.count >= 2 {
            observationTime = splitNames[0] + ":" + splitNames[1]
        }
        //aa += formatDictionaryStr(title: "", str: observation_time_rfc822) + "\n"
        let local_tz_short = dictCurrentObservation["local_tz_short"] as? String ?? "?"
        //aa += formatDictionaryStr(title: "local_tz_short", str: local_tz_short, titleLen: titleLen) + "\n"
        aa += "\(observationTime) \(local_tz_short)\n"
        //--------
        
        let wind_dir = dictCurrentObservation["wind_dir"] as? String ?? "?"
        let wind_degrees = dictCurrentObservation["wind_degrees"] as? Int ?? -1
        let wind_mph = dictCurrentObservation["wind_mph"] as? Int ?? -1
        let wind_gust_mph = dictCurrentObservation["wind_gust_mph"] as AnyObject
        var windGustVal = 0.0
        var windGustStr = ""
        if wind_gust_mph is Double {
            windGustVal = wind_gust_mph as! Double
        } else if wind_gust_mph is String {
            if let mphGust = Double(wind_gust_mph as! String) {
                windGustVal = mphGust
            }
        }
        if windGustVal > 0.0 {
            windGustStr = " Gust \(Int(windGustVal))"
        }
        let wind_string = dictCurrentObservation["wind_string"] as? String ?? "?"
        aa += "Wind \(wind_string) \n"
        aa += "     (\(wind_dir)(\(wind_degrees)) @ \(wind_mph)\(windGustStr) mph)\n"
        
        let weather = dictCurrentObservation["weather"] as? String ?? "?"
        aa += formatDictionaryStr(title: "weather", str: weather, titleLen: titleLen) + "\n"
        
        let visibility_mi = dictCurrentObservation["visibility_mi"] as? String ?? "?"
        aa += formatDictionaryStr(title: "visibility", str: visibility_mi, titleLen: titleLen) + " mi\n"
        
        //let temp_f = dictCurrentObservation["temp_f"] as? Double ?? -99.0
        //aa += formatDictionaryDbl(title: "temp_f", num: temp_f, titleLen: titleLen) + "\n"
        
        let temperature_string = dictCurrentObservation["temperature_string"] as? String ?? "?"
        aa += formatDictionaryStr(title: "temperature", str: temperature_string, titleLen: titleLen) + "\n"
        
        //let dewpoint_f = dictCurrentObservation["dewpoint_f"] as? Double ?? -99.0
        //aa += formatDictionaryDbl(title: "dewpoint_f", num: dewpoint_f, titleLen: titleLen) + "\n"
        
        let dewpoint_string = dictCurrentObservation["dewpoint_string"] as? String ?? "?"
        aa += formatDictionaryStr(title: "dewpoint", str: dewpoint_string, titleLen: titleLen) + "\n"
        
        let relative_humidity = dictCurrentObservation["relative_humidity"] as? String ?? "?"
        aa += formatDictionaryStr(title: "relative humidity", str: relative_humidity, titleLen: titleLen) + "\n"
        
        //let windchill_f = dictCurrentObservation["windchill_f"] as? String ?? "?"
        //aa += formatDictionaryStr(title: "windchill", str: windchill_f, titleLen: titleLen) + "\n"
        
        let windchill_string = dictCurrentObservation["windchill_string"] as? String ?? "?"
        aa += formatDictionaryStr(title: "windchill", str: windchill_string, titleLen: titleLen) + "\n"
        
        //let heat_index_f = dictCurrentObservation["heat_index_f"] as? Double ?? -99.9
        //aa += formatDictionaryDbl(title: "heat_index_f", num: heat_index_f, titleLen: titleLen) + "\n"
        
        let heat_index_string = dictCurrentObservation["heat_index_string"] as? String ?? "?"
        aa += formatDictionaryStr(title: "heat index", str: heat_index_string, titleLen: titleLen) + "\n"
        
        //let feelslike_f = dictCurrentObservation["feelslike_f"] as? String ?? "?"
        //aa += formatDictionaryStr(title: "feelslike_f", str: feelslike_f, titleLen: titleLen) + "\n"
        
        let feelslike_string = dictCurrentObservation["feelslike_string"] as? String ?? "?"
        aa += formatDictionaryStr(title: "feelslike", str: feelslike_string, titleLen: titleLen) + "\n"
        
        //let precip_1hr_in = dictCurrentObservation["precip_1hr_in"] as? String ?? "?"
        //aa += formatDictionaryStr(title: "precip_1hr_in", str: precip_1hr_in, titleLen: titleLen) + "\n"
        
        let precip_1hr_string = dictCurrentObservation["precip_1hr_string"] as? String ?? "-999"
        if precip_1hr_string.range(of:"-999") == nil {
            aa += formatDictionaryStr(title: "precip (1hr)", str: precip_1hr_string, titleLen: titleLen) + "\n"
        }

        let precip_today_in = dictCurrentObservation["precip_today_in"] as? String ?? "?"
        aa += formatDictionaryStr(title: "precip (today)", str: precip_today_in, titleLen: titleLen) + "\n"
        
        //--------------
        let pressure_in = dictCurrentObservation["pressure_in"] as? String ?? "?"
        let pressure_trend = dictCurrentObservation["pressure_trend"] as? String ?? "?"
        var trendText = ""
        switch pressure_trend {
        case "-":
            trendText = "falling"
        case "+":
            trendText = "rising"
        default:
            trendText = "steady"
        }
        aa += formatDictionaryStr(title: "altimeter", str: pressure_in, titleLen: titleLen) + " \(trendText)\n"

        print(aa)

        lblRawDataHeading.text = "\(station_id) for \(observationTime)"
        
        txtRawData.text = aa

        print("😀display_location printed!")

        return myError
    /*
         ========================== current_observation base ===========================
         precip_today_metric -----> 0
    observation_time_rfc822 -> Tue, 26 Sep 2017 19:40:40 -0400
         feelslike_c -------------> 29
    wind_mph ----------------> 0.0 N
    precip_1hr_in -----------> 0.00
    relative_humidity -------> 66%
    dewpoint_f --------------> 69.0 N
         UV ----------------------> 0
    dewpoint_string ---------> 69 F (21 C)
    local_tz_short ----------> EDT
    windchill_string --------> NA
         temp_c ------------------> 27.6 N
    heat_index_string -------> 85 F (29 C)
         pressure_mb -------------> 1009
    pressure_in -------------> 29.79
         windchill_c -------------> NA
    feelslike_string --------> 85 F (29 C)
         forecast_url ------------> http://www.wunderground.com/US/SC/Myrtle_Beach.ht
    heat_index_f ------------> 85.0
    pressure_trend ----------> 0
         ob_url ------------------> http://www.wunderground.com/cgi-bin/findweather/g
    temperature_string ------> 81.7 F (27.6 C)
         estimated ---------------> {Dictionary} with 0 items
         image -------------------> {Dictionary} with 3 items
    wind_degrees ------------> 113.0 N
    precip_today_string -----> 0.00 in (0 mm)
         wind_gust_kph -----------> 0.0 N
         observation_epoch -------> 1506469240
    weather -----------------> Clear
         heat_index_c ------------> 29.0
    feelslike_f -------------> 85
         observation_location ----> {Dictionary} with 8 items
         local_tz_offset ---------> -0400
    precip_today_in ---------> 0.00
    local_time_rfc822 -------> Tue, 26 Sep 2017 19:41:06 -0400
         solarradiation ----------> --
    wind_string -------------> Calm
         history_url -------------> http://www.wunderground.com/weatherstation/WXDail
    windchill_f -------------> NA
         local_epoch -------------> 1506469266
    wind_gust_mph -----------> 0.0 N
         wind_kph ----------------> 0.0 N
         display_location --------> {Dictionary} with 12 items
         icon_url ----------------> http://icons.wxug.com/i/c/k/nt_clear.gif
    precip_1hr_string -------> 0.00 in ( 0 mm)
         local_tz_long -----------> America/New_York
    temp_f ------------------> 81.7 N
         observation_time --------> Last Updated on September 26, 7:40 PM EDT
         icon --------------------> clear
         precip_1hr_metric ------->  0
         dewpoint_c --------------> 21.0 N
    station_id --------------> KSCMYRTL73
    wind_dir ----------------> ESE
         visibility_km -----------> 16.1
    visibility_mi -----------> 10.0
         nowcast -----------------> 
         ======================== end current_observation base =========================
 */
    }//end func DoCurrentObservation
    
    //----------------------- DoGeolookup ---------------------------
    func DoGeolookup (jsonResult: AnyObject) -> String {
        clearRawData()
        guard let dictLocation = jsonResult["location"] as? [String: AnyObject] else {return "\"location\" not in JSON data!!"}
        printDictionary(dict: dictLocation, expandLevels: 0, dashLen: 15, title: "location")
        guard let dictNearby = dictLocation["nearby_weather_stations"] as? [String: AnyObject] else {return "\"nearby_weather_stations\" not in location data!!"}
        printDictionary(dict: dictNearby, expandLevels: 1, dashLen: 11, title: "location")
        
        return ""
    }//end func
    
    
    //----------------------- DoHistory ---------------------------
    func DoHistory (jsonResult: AnyObject) -> String {
        clearRawData()
        guard let dictHistory = jsonResult["history"] as? [String: AnyObject] else {return "\"history\" not in JSON data!!"}
        guard let dailysummaryArr = dictHistory["dailysummary"] as? [[String: AnyObject]] else {return "\"dailysummaryArr\" not in \"history\""}
        guard let observationsArr = dictHistory["observations"] as? [[String: AnyObject]] else {return "\"observationsArr\" not in \"history\""}
        
        print("\n\(dictHistory.count) items in dictHistory")
        printDictionary(dict: dictHistory, expandLevels: 0, dashLen: 0, title: "History")
        
        print("\n\(observationsArr.count) items in observationsArr\n")
        if observationsArr.count > 0 {
            guard let dict = observationsArr.first else {return "No observations in History"}
            printDictionary(dict: dict, expandLevels: 0, dashLen: 0, title: "observationsArr[0]")
        }
        
        print("\n\(dailysummaryArr.count) items in dailysummaryArr")
        if dailysummaryArr.count > 0 {
            guard let dict = dailysummaryArr.first else {return "No dailysummary in History"}
            printDictionary(dict: dict, expandLevels: 0, dashLen: 33, title: "dailysummaryArr[0]")
            
            var aa = ""
            let dictDate = dict["date"] as! [String: AnyObject]
            let dat = dictDate["pretty"] as! String
            let dateArr = dat.components(separatedBy: " on ")
            let date = dateArr.count < 2 ? dat : dateArr[1]
            let minTemp = dict["mintempi"] as? String ?? "?"
            let maxTemp = dict["maxtempi"] as? String ?? "?"
            let minDewP = dict["mindewpti"] as? String ?? "?"
            let maxDewP = dict["maxdewpti"] as? String ?? "?"
            let minVis = dict["minvisi"] as? String ?? "?"
            let maxVis = dict["maxvisi"] as? String ?? "?"
            aa += "Temp    \(minTemp)° to \(maxTemp)°\n"
            aa += "DewPt   \(minDewP)° to \(maxDewP)°\n"
            aa += "Vis    \(minVis) mi to \(maxVis) mi\n"
            lblRawDataHeading.textAlignment = NSTextAlignment.center
            lblRawDataHeading.text = date
            txtRawData.text = aa
        }
        
        /*
         ====== dailysummaryArr[0] ======
         date
         meantempi
         mintempi
         maxtempi
         
         meandewpti
         mindewpti
         maxdewpti
         
         humidity
         minhumidity
         maxhumidity

         meanpressurei
         minpressurei
         maxpressurei
         
         meanvisi
         minvisi
         maxvisi
         
         meanwindspdi
         minwspdi
         maxwspdi

         hail
         precipsource
         monthtodatesnowfalli
         snowdepthi
         snowfalli
         precipi
         tornado
         snow
         since1julsnowfalli
         rain
         fog
         meanwdird
         meanwdire
         thunder

         gdegreedays
         heatingdegreedaysnormal
         monthtodateheatingdegreedays
         monthtodateheatingdegreedaysnormal
         monthtodatecoolingdegreedays
         coolingdegreedaysnormal
         coolingdegreedays
         heatingdegreedays
         monthtodatecoolingdegreedaysnormal
         since1sepcoolingdegreedaysnormal
         since1sepcoolingdegreedays
         since1sepheatingdegreedays
         since1sepheatingdegreedaysnormal
         since1julheatingdegreedaysnormal
         since1julheatingdegreedays
         since1jancoolingdegreedays
         since1jancoolingdegreedaysnormal
         ==== end dailysummary[0] ====

 */
        
        return ""
        
        /*
utcDate
dailysummary()
observations()
date
         */
    }//end func DoHistory
    
    //------------------------------------ DoHurricane ----------------------------------
    func DoHurricane (jsonResult: AnyObject) -> String {
        clearRawData()
        lblRawDataHeading.textAlignment = NSTextAlignment.center
        lblRawDataHeading.text = "No Report from Tropics"       // default label
        guard let hurricaneArr = jsonResult["currenthurricane"] as? [[String: AnyObject]] else {return "\"CurrentHurricane\" not in downloaded data!!"}
        
        print("\n\(hurricaneArr.count) storms in hurricaneArr (jsonResult[\"currenthurricane\"])")
        lblRawDataHeading.text = showCount(count: hurricaneArr.count, name: "Tropical System", ifZero: "No")  //"\(hurricaneArr.count) storms"
        if hurricaneArr.count == 0 { return "" }
        guard let dictHurricane0 = hurricaneArr.first else {return "Hurricane[0] not found!"}
        printDictionary(dict: dictHurricane0, expandLevels: 0, dashLen: 0, title: "currenthurricane[0]")
        //printDictionary(dict: dictHurricane0, expandLevels: 1, dashLen: 0, title: "currenthurricane[0]")
        
        let dictStormInfo0 = dictHurricane0["stormInfo"] as! [String: AnyObject]
        printDictionary(dict: dictStormInfo0, expandLevels: 0, dashLen: 0, title: "dictStormInfo0")
        
        let dictCurrent0 = dictHurricane0["Current"] as! [String: AnyObject]
        printDictionary(dict: dictCurrent0, expandLevels: 0, dashLen: 0, title: "dictCurrent0")
        printDictionary(dict: dictCurrent0, expandLevels: 1, dashLen: 0, title: "dictCurrent0")
        
        //let trackArr0 = dictHurricane0["track"] as! NSArray
        //let trackArr00 = trackArr0[0] as! [String: AnyObject]
        //printDictionaryNS(dictNS: trackArr00, expandLevels: 0, dashLen: 0, title: "trackArr00")
        
        let forecastArr0 = dictHurricane0["forecast"] as! [[String: AnyObject]]
        let forecastArr00 = forecastArr0[0]
        printDictionary(dict: forecastArr00, expandLevels: 0, dashLen: 0, title: "forecastArr00")
        printDictionary(dict: forecastArr00, expandLevels: 1, dashLen: 0, title: "forecastArr00")
        
        let extendedForecastArr0 = dictHurricane0["ExtendedForecast"] as! [[String: AnyObject]]
        if extendedForecastArr0.count > 0 {
            let extendedForecastArr00 = extendedForecastArr0[0]
            printDictionary(dict: extendedForecastArr00, expandLevels: 0, dashLen: 0, title: "extendedForecastArr00")
            printDictionary(dict: extendedForecastArr00, expandLevels: 1, dashLen: 0, title: "extendedForecastArr00")
        }
        var aa = ""
        for dictHurricane in hurricaneArr {
            let dictStormInfo = dictHurricane["stormInfo"]      as! [String: AnyObject]
            let stormNameNice = dictStormInfo["stormName_Nice"]      as? String ?? "stormName missing"

            let dictCurrent   = dictHurricane["Current"]        as! [String: AnyObject]
            let cat           = dictCurrent["SaffirSimpsonCategory"] as? Int    ?? 0
            let lat           = dictCurrent["lat"]                   as? Double ?? -99.0
            let lon           = dictCurrent["lon"]                   as? Double ?? -999.0
            let latLon        = String(format:" %5.1f° ",lat) + String(format:"%5.1f°",lon)

            let dictFSpeed    = dictCurrent["Fspeed"]           as! [String: AnyObject]
            let fSpeedMph     = dictFSpeed["Mph"]                    as? Int    ?? -1

            let dictWindGust  = dictCurrent["WindGust"]         as! [String: AnyObject]
            let windGustMph   = dictWindGust["Mph"]                  as? Int ?? -1

            let dictWindSpeed = dictCurrent["WindSpeed"]        as! [String: AnyObject]
            let windSpeedMph  = dictWindSpeed["Mph"]                 as? Int ?? -1

            let dictMovement  = dictCurrent["Movement"]         as! [String: AnyObject]
            //let movementDeg = dictMovement["Degrees"]              as? String ?? "??"
            let movementText  =  dictMovement["Text"]                as? String ?? "??"

            let dictPressure  = dictCurrent["Pressure"]         as! [String: AnyObject]
            let pressureInches = dictPressure["inches"]              as? Double ?? 0.0
            let pressureMb     = dictPressure["mb"]                  as? Int ?? 0

            let dictTime      = dictCurrent["Time"]             as! [String: AnyObject]
            let wkDay         = dictTime["weekday_name"]             as? String ?? "???"
            let time          = dictTime["pretty"]                   as? String ?? "????"
            
            aa += stormNameNice + "\n"
            aa += "Catagory \(cat) Wind \(windSpeedMph), gusting to \(windGustMph) \n"
            aa += "Located \(latLon)  moving \(movementText) at \(fSpeedMph)\n"
            if pressureMb > 0 || pressureInches > 0.0 {
                aa += String(format: "%6.2f",pressureInches) + " in.    " + String(pressureMb) + " mb\n"}
            aa += "\(wkDay) \(time)\n"
            aa += "\n"
        }
        
        txtRawData.text = aa
        return ""
        
/*
         2 storms in hurricaneArr (jsonResult["currenthurricane"])
         ========================== currenthurricane[0] base ===========================
         stormInfo ------------> {Dictionary} with 5 items
         Current --------------> {Dictionary} with 15 items
         track ----------------> (Array) with 17 "Current" Dictionaries
         forecast -------------> (Array) with 5 items
         ExtendedForecast -----> (Array) with 1 items
         ======================== end currenthuricane[0] base =========================
     
         ========================== dictStormInfo0 base ===========================
         stormName ------------> Lee
         stormName_Nice -------> Hurricane Lee
         stormNumber ----------> at201714
         requesturl -----------> /hurricane/atlantic/2017/Hurricane-Lee
         wuiurl ---------------> http://www.wunderground.com/hurricane/atlantic/20
         ======================== end dictStormInfo0 base =========================
         
         ========================== dictCurrent0 base ===========================
         Category -------------> Hurricane
         SaffirSimpsonCategory -> 2
         lat ------------------> 29.9
         lon ------------------> -53.7
         Time -----------------> {Dictionary} with 21 items
         TimeGMT --------------> {Dictionary} with 20 items
         WindSpeed ------------> {Dictionary} with 3 items  {Kph = 165; Kts =  90; Mph = 105; }
         WindGust -------------> {Dictionary} with 3 items  {Kph = 165; Kts = 110; Mph = 125; }
         WindQuadrants --------> {Dictionary} with 5 items  {comment = "Use these keys ...";"quad_1" = NE;"quad_2" = SE;"quad_3" = SW;"quad_4" = NW;};
         WindRadius -----------> {Dictionary} with 3 items {
            34 =         {NE = 40;NW = 40;SE = 40;SW = 40;};
            50 =         {NE = 30;NW = 30;SE = 30;SW = 30;};
            64 =         {NE = 15;NW = 15;SE = 15;SW = 15;};
                                                            };
         SeaQuadrants ---------> {Dictionary} with 5 items  {comment = "Use these keys ...";"quad_1" = NE;"quad_2" = SE;"quad_3" = SW;"quad_4" = NW;};
         SeaRadius ------------> {Dictionary} with 1 items  { 12 = {NE = 120; NW = 120; SE = 90; SW = 120; }
         Movement -------------> {Dictionary} with 2 items  {Degrees = 265; Text = W; }
         Pressure -------------> {Dictionary} with 2 items  {inches = "28.78"; mb = 975; };
         Fspeed ---------------> {Dictionary} with 3 items  {Kph = 16; Kts = 9; Mph = 10; };

         ======================== end dictCurrent0 base =========================

         ========================== forecastArr00 base ===========================
         Category -------------> 2
         SaffirSimpsonCategory -> 2.0
         lat ------------------> 30.0
         lon ------------------> -55.1
         Time -----------------> {Dictionary} with 21 items
         TimeGMT --------------> {Dictionary} with 18 items
         WindSpeed ------------> {Dictionary} with 3 items
         WindGust -------------> {Dictionary} with 3 items
         WindQuadrants --------> {Dictionary} with 5 items
         WindRadius -----------> {Dictionary} with 3 items

         ErrorRadius ----------> 0.50
         ForecastHour ---------> 12HR
         ======================== end forecastArr00 base =========================
         
         ========================== extendedForecastArr00 base ===========================
         Category -------------> Tropical Storm
         SaffirSimpsonCategory -> 0.0
         lat ------------------> 46.0
         lon ------------------> -35.0
         Time -----------------> {Dictionary} with 21 items
         TimeGMT --------------> {Dictionary} with 20 items
         WindSpeed ------------> {Dictionary} with 3 items
         WindGust -------------> {Dictionary} with 3 items
         WindQuadrants --------> {Dictionary} with 5 items
         WindRadius -----------> {Dictionary} with 3 items

         ErrorRadius ----------> 1.92
         ForecastHour ---------> 4DAY
         ======================== end extendedForecastArr00 base =========================

*/
    }//end func DoHurricane
    
    //----------------------------- DoForecast --------------------------------
    func DoForecast (jsonResult: AnyObject) -> String {
        //var myError = ""
        clearRawData()
        lblRawDataHeading.font = txtRawData.font
        guard let dictForecast = jsonResult["forecast"] as? [String: AnyObject] else {return "\"Forecast\" not in downloaded data!!"}
        
        printDictionary(dict: dictForecast, expandLevels: 0, dashLen: 0, title: "Forecast")
        print()
        
        if let dictTxtForecast = dictForecast["txt_forecast"] as? [String: AnyObject] {
            printDictionary(dict: dictTxtForecast, expandLevels: 0, dashLen: 0, title: "Txt_Forecast")
            print()
            lblRawDataHeading.text = dictTxtForecast["date"] as? String
        }
        
        guard let dictSimpleForecast = dictForecast["simpleforecast"] as? [String: AnyObject] else {return "\"simpleforecast\" not in dictForecast"}

        printDictionary(dict: dictSimpleForecast, expandLevels: 0, dashLen: 0, title: "SimpleForecast")
        print()
        
        guard let simpForecastDaysArr = (dictSimpleForecast["forecastday"] as? NSArray) else {return "\"simpForecastDaysArr\" not in dictSimpleForecast"}
        print("\(simpForecastDaysArr.count) entries in simpForecastDaysArr.")
        
        var aa = ""
        for i in 0..<simpForecastDaysArr.count {
            guard let dictSimpForecastDay = (dictSimpleForecast["forecastday"] as? NSArray)?[i] as? [String: AnyObject]
                else {return "\"dictSimpForecastDay\" not in dictSimpleForecast[\(i)]"}
            let dictDate = dictSimpForecastDay["date"] as! [String: AnyObject]
            if i == 0 {
                printDictionary(dict: dictSimpForecastDay, expandLevels: 0, dashLen: 0, title: "SimpForecastDay0")
                printDictionary(dict: dictDate, expandLevels: 0, dashLen: 0, title: "Date0")
            }

            let weekD = dictDate["weekday_short"] as! String
            let mo    = dictDate["monthname_short"] as! String
            var da    = String(dictDate["day"] as! Int)
            if  da.count <= 1 {da = "0" + da}
            let date  = "\(weekD) \(mo) \(da)  "
            let cond  = dictSimpForecastDay["conditions"] as! String

            //var a = ""
            let dictLow = dictSimpForecastDay["low"] as! [String: AnyObject]
            var tLow = dictLow["fahrenheit"] as! String
            if tLow.hasPrefix("-999") { tLow = "--" }
            let dictHigh = dictSimpForecastDay["high"] as! [String: AnyObject]
            let tHigh = dictHigh["fahrenheit"] as! String
            let pop = String(dictSimpForecastDay["pop"] as! Int)
            //let dictQpfDay = dictSimpForecastDay["qpf_day"] as! [String: AnyObject]
            //let qpfDay = dictQpfDay["in"] as? Double ?? 0.0
            aa += "\(date) \(tHigh.rightJust(3))℉ \(tLow.rightJust(3))℉ \(pop.rightJust(3))% \(cond) \n\n"
        }//next i
        
        lblRawDataHeading.textAlignment = NSTextAlignment.left
        lblRawDataHeading.text = "   Date       High  Low   PoP  Conditions   "
        self.txtRawData.text = aa

        return ""
/*
period      1
qpf_day     { in = "<null>"; mm = "<null>" }
qpf_allday  { in = 0; mm = 0 }
qpf_night   { in = 0; mm = 0 }
snow_allday { cm = 0; in = 0 }
snow_day    { cm = "<null>": in = "<null>" }
snow_night  { cm = 0: in = 0 }
low         { celsius = 19: fahrenheit = 67 }
high        { celsius = 29: fahrenheit = 85 }
minhumidity 0
maxhumidity 0
avehumidity 89
conditions  Clear
skyicon
maxwind     { degrees = 0; dir = "-999"; kph = 23; mph = "-999" }
avewind     { degrees = 0; dir = North;  kph = 11; mph = 7 }
pop         10
icon        clear
icon_url    http://icons.wxug.com/i/c/k/clear.gif
date {
         pretty = "7:00 PM EDT on September 18, 2017";
         epoch  = 1505775600; yday = 260;
         year   = 2017; month  = 9;  day    = 18;
         hour   = 19;   min    = 00; sec    = 0; ampm   = PM; isdst  = 1;
         monthname = September;          "monthname_short" = Sep;
         "tz_long" = "America/New_York"; "tz_short"        = EDT;
         weekday   = Monday;             "weekday_short"   = Mon;
}
*/
        
    }//end func DoForecast

    //-------------------------- DoHourly -----------------------
    func DoHourly(jsonResult: AnyObject) -> String {
        let myError = ""
        clearRawData()
        lblRawDataHeading.font = txtRawData.font

        guard let dictHourlyArr = jsonResult["hourly_forecast"] as? [[String: AnyObject]] else {return "Err4: \"hourly\" not in downloaded data!"}
        print("------------ hourlyArr[0] -----------")
        print("hourlyArr.count = \(dictHourlyArr.count)")
        var aa = ""
        printDictionary(dict: dictHourlyArr.first, expandLevels: 0, dashLen: 0, title: "HourlyArr[0]")
        printDictionary(dict: dictHourlyArr.first, expandLevels: 1, dashLen: 0, title: "HourlyArr[0]")

        for dictHourly in dictHourlyArr {
            let d = dictHourly["FCTTIME"] as! [String: AnyObject]
            let weekD = d["weekday_name_abbrev"] as! String
            let mo = d["mon_padded"] as! String
            let da = d["mday_padded"] as! String
            let hr = d["hour_padded"] as! String
            let mn = d["min"] as! String
            //let ampm = d["ampm"] as! String
            let nHr = Int(hr)!
            if nHr < 9 || nHr > 18 { continue }
            if nHr == 9 { aa += "\n" }
            aa += "\(weekD) \(mo)/\(da) \(hr):\(mn) "
            var pop = dictHourly["pop"] as! String
            if pop.count == 1 { pop = " " + pop }
            var wx = dictHourly["wx"] as! String
            wx = wx.replacingOccurrences(of: "Thunder", with: "T-")
            wx = wx.replacingOccurrences(of: "Scattered", with: "Sct")
            wx = wx.replacingOccurrences(of: "Isolated", with: "Iso")
            let temp = hourlyEnglishOrMetric(key: "temp", dict: dictHourly, isMetric: false)
            let dewP = hourlyEnglishOrMetric(key: "dewpoint", dict: dictHourly, isMetric: false)
            aa += " \(pop)%   \(temp)°/\(dewP)° \(wx) \n"
        }
        lblRawDataHeading.textAlignment = NSTextAlignment.left
        lblRawDataHeading.text = " Day Date Hour  Precip Temp/DewPt       Wx"
        txtRawData.text = aa
        return myError
    /*
         hourlyArr.count = 36
         ------------ hourlyArr[0] -----------
         pop -->        15
         uvi -->         7
         fctcode -->     2
         icon -->       partlycloudy
         icon_url -->   http://icons.wxug.com/i/c/k/partlycloudy.gif
         humidity -->   63
         condition -->  Partly Cloudy
         wx -->         Partly Cloudy
         sky -->        34
         wdir -->       {degrees = 144;     dir = SE;}
         wspd -->       {english = 5;       metric = 8;}
         temp -->       {english = 86;      metric = 30;}
         dewpoint -->   {english = 72;      metric = 22;}
         heatindex -->  {english = 92;      metric = 33;}
         feelslike -->  {english = 92;      metric = 33;}
         windchill -->  {english = "-9999"; metric = "-9999";}
         snow -->       {english = "0.0";   metric = 0;}
         mslp -->       {english = "30.02"; metric = 1017;}
         qpf -->        {english = "0.0";   metric = 0;}

         FCTTIME --> {UTCDATE = ""; age = ""; ampm = PM; civil = "12:00 PM"; epoch = 1506009600;
         hour = 12; "hour_padded" = 12;
         isdst = 1; mday = 21; "mday_padded" = 21; min = 00; "min_unpadded" = 0;
         mon = 9; "mon_abbrev" = Sep; "mon_padded" = 09; "month_name" = September; "month_name_abbrev" = Sep;
         pretty = "12:00 PM EDT on September 21, 2017";
         sec = 0;tz = "";
         "weekday_name"       =  Thursday;     "weekday_name_abbrev" = Thu; "weekday_name_unlang" = Thursday;
         "weekday_name_night" = "Thursday Night";                           "weekday_name_night_unlang" = "Thursday Night";
         yday = 263;year = 2017;
         }
    */
    }//end func DoHourly
    
    //
    func hourlyEnglishOrMetric(key: String, dict: [String: AnyObject], isMetric: Bool) -> String {
        let sysKey = isMetric ? "metric" : "english"
        guard let d = dict[key] as? [String: AnyObject] else { return "?" }
        guard let val = d[sysKey] as? String else { return "?int?" }
        return val
    }//end func
    
    //------------------------- DoPlanner ------------------------
    func DoPlanner(jsonResult: AnyObject, isMetric: Bool = false) -> String {
        clearRawData()
        txtRawData.font = UIFont(name: rawFontDefault!.fontName, size: 15)

        guard let dictTrip = jsonResult["trip"] as? [String: AnyObject] else {return "\"planner\" not in downloaded data!"}

        printDictionary(dict: dictTrip, expandLevels: 0, dashLen: 0, title: "Trip")
        printDictionary(dict: dictTrip, expandLevels: 1, dashLen: 0, title: "Trip")
        guard let dictDates = dictTrip["period_of_record"] as? [String: AnyObject] else {return "\"period_of_record\" not in \"planner\" data!"}

        guard let dictDateStartx = dictDates["date_start"] as? [String: AnyObject] else {return "\"date_start\" not in \"planner\" data!"}
        guard let dictDateStart = dictDateStartx["date"] as? [String: AnyObject] else {return "\"date\" not in \"date_start\" data!"}
        let monthStart = dictDateStart["monthname_short"] as? String ?? "???"
        let dayStart = dictDateStart["day"] as? Int ?? 0
        let yearStart = dictDateStart["year"] as? Int ?? 0

        guard let dictDateEndx = dictDates["date_end"] as? [String: AnyObject] else {return "\"date_end\" not in \"planner\" data!"}
        guard let dictDateEnd = dictDateEndx["date"] as? [String: AnyObject] else {return "\"date\" not in \"date_end\" data!"}
        let monthEnd = dictDateEnd["monthname_short"] as? String ?? "???"
        let dayEnd = dictDateEnd["day"] as? Int ?? 0
        let yearEnd = dictDateEnd["year"] as? Int ?? 0

        var title = dictTrip["title"] as? String ?? "title = ?"
        let ap = dictTrip["airport_code"] as? String ?? "?"
        title = title.replacingOccurrences(of: " for ", with: " ")
        title = title.replacingOccurrences(of: "Historical Summary", with: "")
        title = ap + title
        var a2 = "\(ap) \(monthStart) \(dayStart) \(yearStart) to \(monthEnd) \(dayEnd) \(yearEnd)\n"
        //a2 += "Airport Code  \(ap)\n"
        //"Planner for \(ap) \(monthStart) \(dayStart) \(yearStart) to \(monthEnd) \(dayEnd)"
        DispatchQueue.main.async {
            self.lblRawDataHeading.text = title
        }
      
        let dictCloudCover = dictTrip["cloud_cover"] as! [String: AnyObject]
        let cond  = dictCloudCover["cond"] as! String
        a2 += "Cloud Cover = \(cond)\n"
        a2 += "               Min    Avg    Max\n"
        
        let precip = plannerInchMinAvgMax(key: "precip", dictSource: dictTrip)
        let unitsP = isMetric ? "cm" : "in"
        a2 += "precip (\(unitsP)) \(precip.min) \(precip.avg) \(precip.max)\n"

        let tempLow = plannerDegMinAvgMax(key: "temp_low", dictSource: dictTrip)
        a2 += "Low  Temp     \(tempLow.min)°   \(tempLow.avg)°   \(tempLow.max)°\n"
        let tempHigh = plannerDegMinAvgMax(key: "temp_high", dictSource: dictTrip)
        a2 += "High Temp     \(tempHigh.min)°   \(tempHigh.avg)°   \(tempHigh.max)°\n"

        let dewpointLow = plannerDegMinAvgMax(key: "dewpoint_low", dictSource: dictTrip)
        a2 += "Low  dewpoint \(dewpointLow.min)°   \(dewpointLow.avg)°   \(dewpointLow.max)°\n"
        let dewpointHigh = plannerDegMinAvgMax(key: "dewpoint_high", dictSource: dictTrip)
        a2 += "High dewpoint \(dewpointHigh.min)°   \(dewpointHigh.avg)°   \(dewpointHigh.max)°\n"

        //let dictPeriodOfRecord = dictTrip["period_of_record"] as! [String: AnyObject]
        //let dictCloudCover = dictTrip["cloud_cover"] as! [String: AnyObject]
        
        guard let dictChanceOf = dictTrip["chance_of"] as? [String: AnyObject] else {return "No \"ChanceOf\" found"}

        //let lat = ((dictTrip["tripInfo"] as? NSArray)?[0] as? [String: AnyObject])?["lat"] as? String
        
        printDictionary(dict: dictChanceOf, expandLevels: 0, dashLen: 0, title: "chance_of")
        printDictionary(dict: dictChanceOf, expandLevels: 1, dashLen: 0, title: "chance_of")

        a2 += "\n    ----- Chance of -----\n"

        var pctSunny = ""
        var pctPartlyCloudy = ""
        var pctCloudy = ""

        var pctTempBelowFreezing = ""
        var pctTempOverFreezing = ""
        var pctTempOver60 = ""
        var pctTempOver90 = ""

        var pctDP70plus = ""
        var pctDP60plus = ""

        var dictChanceOfUnhandled = [String: AnyObject]()
        // Scan through dictChanceOf, pick off certain items, and place the rest in dictChanceOfUnhandled
        for (key, value) in dictChanceOf {
            let dict = value as! [String: AnyObject]

            //let name = dict["name"] as? String ?? "??"
            let pct = dict["percentage"] as? String ?? "??"
            //let desc = dict["description"] as? String ?? "Description = ?"

            switch key {
            case "chanceofsunnycloudyday":
                pctSunny = pct
            case "chanceofpartlycloudyday":
                pctPartlyCloudy = pct
            case "chanceofcloudyday":
                pctCloudy = pct

            case "tempbelowfreezing":
                pctTempBelowFreezing = pct
            case "tempoverfreezing":
                pctTempOverFreezing = pct
            case "tempoversixty":
                pctTempOver60 = pct
            case "tempoverninety":
                pctTempOver90 = pct

            case "chanceofhumidday":
                pctDP60plus = pct
            case "chanceofsultryday":
                pctDP70plus = pct
            default:
                dictChanceOfUnhandled[key] = value
            }

        }//next

        a2 += "Sky  Cloudy  PartlyCloudy   Sunny\n"
        a2 += "       \(pctCloudy)%        \(pctPartlyCloudy)%        \(pctSunny)%\n\n"
        a2 += "Temp  <32   32-59   60-89   90+\n"
        a2 += "       \(pctTempBelowFreezing)%     \(pctTempOverFreezing)%     \(pctTempOver60)%    \(pctTempOver90)%\n\n"
        var pctDP60Minus = ""
        if isNumeric(pctDP60plus) && isNumeric(pctDP70plus) {
            pctDP60Minus = String(100 - Int(pctDP60plus)! - Int(pctDP70plus)!)
        }
        a2 += "Dewpoint   <60    >60    >70\n"
        a2 += "           \(pctDP60Minus)%    \(pctDP60plus)%     \(pctDP70plus)%\n\n"
        print(pctCloudy, pctPartlyCloudy, pctSunny)
        print(pctTempBelowFreezing,pctTempOverFreezing,pctTempOver60,pctTempOver90)
        print(pctDP60plus, pctDP70plus)

        // for each dictionary item not accounted for, show name,pct,desc
        for (_,value) in dictChanceOfUnhandled {
            let dict = value as! [String: AnyObject]

            let name = dict["name"] as? String ?? "??"
            var pct = dict["percentage"] as? String ?? "??"
            var desc = dict["description"] as? String ?? "Description = ?"

            if pct.count == 1 { pct = " " + pct }
            desc = desc.replacingOccurrences(of: "average wind over", with: "avg >")
            desc = desc.replacingOccurrences(of: "&deg;", with: "°")
            desc = desc.replacingOccurrences(of: " / ", with: "/")
            desc = desc.replacingOccurrences(of: "over ", with: "> ")
            desc = desc.replacingOccurrences(of: "below ", with: "< ")
            desc = desc.replacingOccurrences(of: "temperature ", with: "")
            a2 += "\(pct)% of \(name)"
            if desc != "" {a2 += " (\(desc))"}
            a2 += "\n"
        }//next
        
        txtRawData.text = a2

        return ""
        /*
         ========================== Trip expanded ===========================
         period_of_record -> {
            "date_end"   =  {date = { see "== date ==" }}
            "date_start" =  {date = { see "== date ==" }}
         }
         error ------------> ""
         airport_code -----> "KCRE"
         dewpoint_high ----> {avg={C=8; F=46}; max={C=19; F=66}; min={C="-10"; F = 14}}
         precip -----------> {avg={cm="1.3"; in="0.05"}; max={cm="16.3"; in="0.64"}; min={cm="0.0"; in="0.00"}}
         title ------------> Historical Summary for January 01 - January 07
         chance_of --------> {
            chanceofcloudyday  = {description = ""; name = Cloudy; percentage = 36}
            chanceoffogday     = {description = ""; name = Fog;    percentage = 29}
            chanceofhailday    = {description = ""; name = Hail;   percentage =  0}
            chanceofhumidday   = {description = "dew point over 60&deg;F / 16&deg;C"; name = Humid; percentage =  14}
            chanceofpartlycloudyday = {description = ""; name = Partly Cloudy; percentage = 10}
            chanceofprecip     = {description = ""; name = Precipitation; percentage = 38}
            chanceofrainday    = {description = ""; name = Rain;   percentage = 38}
            chanceofsnowday    = {description = ""; name = Snow;   percentage =  2}
            chanceofsnowonground = {description = ""; name = "Ground Snow";   percentage =  0}
            chanceofsultryday  = {description = "dew point over 70&deg;F / 21&deg;C"; name = Sweltering;   percentage =  0}
            chanceofsunnycloudyday = {description = ""; name = Sunny; percentage = 55}
            chanceofthunderday = {description = ""; name = Thunderstorms; percentage =  2}
            chanceoftornadoday = {description = ""; name = Tornado; percentage =  0}
            chanceofwindyday   = {description = "average wind over 10 mph / 15km/h"; name = Windy; percentage = 10}
            tempbelowfreezing  = {description = "temperature below 32&deg;F / 0&deg;C"; name = Freezing; percentage =  2}
            tempoverfreezing   = {description = "temperature between 32&deg;F / 0&deg;C and 60&deg;F / 16&deg; C"; name = Cool; percentage = 55}
            tempoverninety     = {description = "temperature over 90&deg;F / 32&deg;C"; name = Hot; percentage =  0}
            tempoversixty      = {description = "temperature over 60&deg;F / 16&deg;C and below 90&deg;F / 32&deg;C"; name = Warm; percentage = 55}
         }
         cloud_cover ------> {cond = "mostly sunny"}
         dewpoint_low -----> {avg = {C = "-2"; F = 29;}; max = {C = 16; F = 60;}; min = {C = "-21"; F = "-5"}}
         temp_high --------> {avg = {C = "14"; F = 56;}; max = {C = 22; F = 71;}; min = {C =  "-1"; F = "31"}}
         temp_low ---------> {avg = {C =  "3"; F = 38;}; max = {C = 16; F = 61;}; min = {C =  "-8"; F = "18"}}
         ======================== end Trip expanded =========================
         
         ============ date =========
         ampm = PM;
         day = 7;
         epoch = 1483808400;
         hour = 12;
         isdst = 0;
         min = 00;
         month = 1;
         monthname = January;
         "monthname_short" = Jan;
         pretty = "12:00 PM EST on January 07, 2017";
         sec = 0;
         "tz_long" = "America/New_York";
         "tz_short" = EST;
         weekday = Saturday;
         "weekday_short" = Sat;
         yday = 6;
         year = 2017;
         ===========================
 */
    }//end func doPlanner
    
    
    // ------ Extract (min, avg, max)degrees from JSON{avg = {C = ""; F = "";}; max = {C = ""; F = "";}; min = {C =  ""; F = ""}} ---
    func plannerDegMinAvgMax(key: String, dictSource: [String: AnyObject], isMetric: Bool = false) -> (min:String, avg:String, max:String) {
        guard let dictMain = dictSource[key] as? [String: AnyObject] else {return ("?", "?", "?")}
        let dict = plannerMinAvgMax(dict: dictMain)
        
        let degType = isMetric ? "C" : "F"
        let min = dict.min?[degType] as? String ?? "??"
        let avg = dict.avg?[degType] as? String ?? "??"
        let max = dict.max?[degType] as? String ?? "??"
        let min3 = min.rightJust(3)
        let avg3 = avg.rightJust(3)
        let max3 = max.rightJust(3)
        return (min3, avg3, max3)
    }
    
    // ------ Extract (min, avg, max)degrees from JSON{avg = {avg={cm=""; in=""}; max={cm=""; in=""}; min={cm=""; in=""}} ---
    func plannerInchMinAvgMax(key: String, dictSource: [String: AnyObject], metric: Bool = false) -> (min:String, avg:String, max:String) {
        guard let dictMain = dictSource[key] as? [String: AnyObject] else {return ("?", "?", "?")}
        let dict = plannerMinAvgMax(dict: dictMain)
        let units = metric ? "cm" : "in"
        let min = dict.min?[units] as? String ?? "??"
        let avg = dict.avg?[units] as? String ?? "??"
        let max = dict.max?[units] as? String ?? "??"
        let min6 = min.rightJust(6)
        let avg6 = avg.rightJust(6)
        let max6 = max.rightJust(6)
        return (min6, avg6, max6)
    }
    
    func plannerMinAvgMax(dict: [String: AnyObject]) -> (min: [String: AnyObject]?, avg: [String: AnyObject]?, max: [String: AnyObject]?) {
        let min = dict["min"] as? [String: AnyObject]
        let avg = dict["avg"] as? [String: AnyObject]
        let max = dict["max"] as? [String: AnyObject]
        return (min, avg, max)
    }
    
    //------------------------------ DoTide --------------------------------
    func DoTide(jsonResult: AnyObject) -> String {
        
        clearRawData()
        txtRawData.font = UIFont(name: rawFontDefault!.fontName, size: 14)
        var myError = ""
        
        guard let dictTide = jsonResult["tide"] as? [String: AnyObject] else {return "\"tide\" not in downloaded data!"}
        
        printDictionary(dict: dictTide, expandLevels: 0, dashLen: 0, title: "Tide")
        print()

        guard let dictTideInfoArr = dictTide["tideInfo"] as? [[String: AnyObject]] else {return "Could not get tideinfo"}
        let dictTideInf0 = dictTideInfoArr[0]
        //let lat = ((dictTide["tideInfo"] as? NSArray)?[0] as? [String: AnyObject])?["lat"] as? String
        
        guard let TideSummaryArr = dictTide["tideSummary"] as? [[String: AnyObject]] else { return "Could not create \"TideSummaryArr\"" }
        
        guard let TideSummaryStatsArr = dictTide["tideSummaryStats"] as? [[String: AnyObject]] else { return "Could not create \"TideSummaryStatsArr\"" }
        let dictTideSummaryStats0 = TideSummaryStatsArr[0]
        
        //print("========================== tideInfo ===========================")
        var aa = "----- tideInfo -----\n"

        printDictionary(dict: dictTideInf0, expandLevels: 0, dashLen: 0, title: "tideInfo")
        printDictionary(dict: dictTideInf0, expandLevels: 1, dashLen: 0, title: "tideInfo")
        
        guard let site  = dictTideInf0["tideSite"] as? String else { return "No tide info available" }
        guard let lat   = dictTideInf0["lat"]      as? String else { return "No Lat for tide" }
        guard let lon   = dictTideInf0["lon"]      as? String else { return "No Lon for tide" }
        guard let units = dictTideInf0["units"]    as? String else { return "No units for tide" }
        if site == "" {
            self.lblRawDataHeading.text = "No Tide Information"
            return "No tideSite info available"
        }
        lblRawDataHeading.text = site
        aa = "measured in \(units) at \(lat) \(lon) \n"
        //print("========================== end tideInfo ===========================")
        //print()

        //print("========================= tideSummaryStats ===========================")
        //aa += "\n----- tideSummaryStats -----\n"
        
        printDictionary(dict: dictTideSummaryStats0, expandLevels: 0, dashLen: 0, title: "tideSummaryStats")
        printDictionary(dict: dictTideSummaryStats0, expandLevels: 1, dashLen: 0, title: "tideSummaryStats")

        guard let maxHeight  = dictTideSummaryStats0["maxheight"] as? Double else { return "No maxHeight for tide" }
        guard let minHeight  = dictTideSummaryStats0["minheight"] as? Double else { return "No minHeight for tide" }
        aa += "Min Height = \(minHeight) \(units)\n"
        aa += "Max Height = \(maxHeight) \(units)\n"
        
        //print("========================= end tideSummaryStats ===========================")
        //print()
        
        print(TideSummaryArr.count, " entries in Tide Summary Array")
        print()

        if TideSummaryArr.count >= 1 {
            printDictionary(dict: TideSummaryArr[0], expandLevels: 1, dashLen: 0, title: "TideSummaryArr[0]")
        } else {
            aa += "\n--- Tide Info Missing! ---"
        }
        var prevDay = ""
        for dictTideSummary in TideSummaryArr {
            //let dictTideSummary = tideSummary as! [String: AnyObject]
            let dictData = dictTideSummary["data"] as! [String: AnyObject]
            let dictDate = dictTideSummary["date"] as! [String: AnyObject]
            let datePretty = dictDate["pretty"] as? String ?? "nil on nil"
            print(dictDate["pretty"]!, dictData["type"]!,  dictData["height"]!)

            let timeDate = datePretty.components(separatedBy: " on ")

            var strTime = timeDate[0]
            let timeZoneAbr = strTime.right(3)
            let monStr = dictDate["mon"]  as? String ?? "??"
            let dayStr = dictDate["mday"] as? String ?? "??"
            let yrStr =  dictDate["year"] as? String ?? "????"
            var strDate = "\(monStr)/\(dayStr)"
            var strType = dictData["type"]   as? String ?? "?"

            var strHt   = dictData["height"] as? String ?? "?"

            //for small iPhone (7), remove "ft" if it would wrap line (??? needs check for wC)
            if strHt != "" {
                let htSplit = strHt.components(separatedBy: " ")
                let ht = Double(htSplit[0]) ?? 0
                let unit = htSplit.count>1 && ht >= 0 && ht < 9.94 ? htSplit[1] : ""
                strHt = formatDbl(number: ht, places: 1) + unit
            }
            let mon  = Int(monStr)
            let day  = Int(dayStr)
            let year = Int(yrStr)
            var dateComponents = DateComponents(calendar:Calendar.current, year:year, month:mon, day:day)
            dateComponents.timeZone = TimeZone(abbreviation: timeZoneAbr)
            if dateComponents.isValidDate {
                let localDate = dateComponents.date!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE MMM dd"
                strDate = dateFormatter.string(from: localDate)
                print(strDate)
            }
            let char2 = strTime[strTime.index(strTime.startIndex, offsetBy: 1)]
            if char2 == ":" {
                strTime = " " + strTime
            }
            strType = strType.replacingOccurrences(of: "Low", with: " Low")// == "Low" {strType = " Low"}
            let newLine = "\(strDate) \(strTime) \(strType) \(strHt)"
            if dayStr != prevDay {
                print()
                aa += "\n"
                prevDay = dayStr
            }
            print(newLine)
            aa += "\(newLine)\n"
        }
        
        DispatchQueue.main.async {
            self.txtRawData.text = aa
            //self.txtRawData.text = a1
        }
        print("😀tideInfo printed!")
        
        myError = ""
        
        return myError
        
    }//end func DoTide
    
  //===========================================================================
}
/* wunderground keywords
["alerts", "almanac", "astronomy", "conditions", "currenthurricane",
"forecast", "forecast10day", "geolookup", "history", "hourly", "hourly10day",
"planner", "rawtide", "satellite", "tide", "webcams", "yesterday"]

 * alerts           response --> ...,  alerts -----> ..., query_zone --> 005
 * almanac          response --> ...,  almanac ----> ...
 * astronomy        response --> ...,  sun_phase --> ..., moon_phase -->  ...
 * conditions       response --> ...,  current_observation --> ...
 * currenthurricane response --> ...,  currenthurricane -----> ...
 * forecast         response --> ...,  forecast ---> ...
 * forecast10day    response --> ...,  forecast ---> ...
 * geolookup        response --> ...,  location ---> ...
 * history          response --> ...,  history ----> ...
 * hourly           response --> ...,  hourly_forecast --> ...
 * hourly10day      response --> ...,  hourly_forecast --> ...
 * planner          response --> ...,  trip -------> ...
 * rawtide          response --> ...,  rawtide ----> ...
 * satellite        response --> ...,  satellite --> ...
 * tide             response --> ...,  tide -------> ...
 * webcams          response --> ...,  webcams ----> ...
 * yesterday        response --> ...,  history ----> ...
*/
