//
//  GeoLookup-ViewController.swift
//  Weather Central
//
//  Created by George Bauer on 9/28/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

//TODO:
/*
    3. .isEnabled for btnSave
    4. Autocomplete for txtCity
    5. Limit Calls to below 10/min 500/day
 
*/

import UIKit
import CoreLocation
//MARK:---- Globals ----
var gSearchType = ""
var gSearchName = ""
var gSearchLat  = 0.0
var gSearchLon  = 0.0
var gLatFromMap = 0.0
var gLonFromMap = 0.0
var gMapDidUpdate = false
var gStations   = [Station]()

class GeoLookup_ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    //MARK: ---- my vars ----
    var zip = "-----"
    var Detail = ""
    var selectedStationID = ""
    var infoStations = [StationInfo]()
    var latStr = "?"
    var lonStr = "?"

    var locationManager = CLLocationManager()
    var userLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    //var userLat: Double = 0
    //var userLon: Double = 0
    //MARK: ---- IBOutlet's ----
    @IBOutlet weak var tableView:  UITableView!

    @IBOutlet weak var txtCity:    UITextField!
    @IBOutlet weak var txtState:   UITextField!
    @IBOutlet weak var txtLat:     UITextField!
    @IBOutlet weak var txtLon:     UITextField!
    @IBOutlet weak var txtZip:     UITextField!
    @IBOutlet weak var txtAirport: UITextField!

    @IBOutlet weak var lblError:   UILabel!
    @IBOutlet weak var lblDetail:  UILabel!

    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var btnCity: UIButton!
    @IBOutlet weak var btnLatLon: UIButton!
    @IBOutlet weak var btnStation: UIButton!
    @IBOutlet weak var btnZip: UIButton!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnMap: UIButton!

    //MARK: ---- iOS built-in functions & overrides ----
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {

        // Start process to get user location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if !gUpdateGeoLookup {return}
        enableButton(btn: btnMap, enable: false)
        
        // Get City, State, Station from permanent storage & set button states
        gCity = UserDefaults.standard.object(forKey: "wucity") as? String ?? ""
        txtCity.text = gCity

        gState = UserDefaults.standard.object(forKey: "wustate") as? String ?? ""
        txtState.text = gState
        enableButton(btn: self.btnCity, enable: self.cityStateIsValid())

        gStationID = UserDefaults.standard.object(forKey: "wuStationID") as? String ?? ""
        txtAirport.text = gStationID
        enableButton(btn: btnStation, enable: stationIsValid())
        
        btnCity.isEnabled = gCity.count >= 2 && gState.count >= 2
        btnCity.backgroundColor = btnCity.isEnabled ? colorButtonNorm : colorButtonGray   //blue=(0x007AFF)

        let n = gStationID.count
        btnStation.isEnabled = (n == 3 || n == 4) || (n >= 8 && n <= 11)
        
        btnLatLon.isEnabled = false
        btnLatLon.backgroundColor = colorButtonGray
        btnZip.isEnabled = false
        btnZip.backgroundColor = colorButtonGray
        
        // Clean out the Stations arrays & clear the TableView
        gStations = []
        infoStations = []
        tableView.reloadData()
        
        lblError.text = ""
        lblDetail.text = "Find the weather station you want, then tap \"Save\" to use it for your query."

    }
    override func viewDidAppear(_ animated: Bool) {
        if gMapDidUpdate {
            gMapDidUpdate = false
            print("😃😃😃😃Update Map to \(gLatFromMap), \(gLonFromMap)😃😃😃😃")
            txtLat.text = formatDbl(number: gLatFromMap, places: 4)
            txtLon.text = formatDbl(number: gLonFromMap, places: 4)
        }

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
        if textField.tag == 101 {
            print("textField tag = \(textField.tag)")
            DoAirportCode()
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: ---- IBAction's ----
    @IBAction func txtCityChanged(_ sender: UITextField) {
        enableButton(btn: btnCity, enable: cityStateIsValid())
    }
    @IBAction func txtStateChanged(_ sender: UITextField) {
        enableButton(btn: btnCity, enable: cityStateIsValid())
    }

    @IBAction func txtLatChanged(_ sender: UITextField) {
        enableButton(btn: btnLatLon, enable: latLonIsValid())
    }
    @IBAction func txtLonChanged(_ sender: UITextField) {
        enableButton(btn: btnLatLon, enable: latLonIsValid())
    }
    
    //---- Limit Airport Codes to 11 characters ----
    @IBAction func txtAirportChanged(_ sender: Any) {
        let text = txtAirport.text!
        let nChars = text.count
        lblError.text = ""
        if nChars > 11 {
            lblError.text = "No more than 11 characters allowed."
            txtAirport.deleteBackward()
        }
        enableButton(btn: btnStation, enable: stationIsValid())
    }
    
    //---- Limit Zip to 5 digits only ----
    @IBAction func txtZipChanged(_ sender: Any) {
        let text = txtZip.text!
        let nChars = text.count
        lblError.text = ""
        if nChars > 0 {
            if nChars > 5 {
                lblError.text = "Only a 5-digit zip allowed."
                txtZip.deleteBackward()
            }
            if !isStringAnInt(text) {
                lblError.text = "Zip must be a number."
                txtZip.deleteBackward()
            }
        }
        enableButton(btn: btnZip, enable: zipIsValid())
    }
    
    //MARK: ---------- Button Actions ----------
    @IBAction func btnLatLonPress(_ sender: Any) {
        self.view.endEditing(true)
        let latTxt = txtLat.text!
        let lonTxt = txtLon.text!
        if lonTxt == "" || lonTxt == "" {showError("You must fill in both\nLatitude and Longitude")}
        guard let lat = Double(latTxt) else {showError("Lat must be a number,\nNOT \(latTxt)"); return}
        guard let lon = Double(lonTxt) else {showError("Lon must be a number,\nNOT \(lonTxt)"); return}
        if lat > 90 || lat < -90 {
            showError("\(lat) is not a legal Latitude.\nIt must be between -90.0 and 90.0")
            return
        }
        if lon > 180 || lon < -180 {
            showError("\(lon) is not a legal Longitude.\nIt must be between -180.0 and 180.0")
            return
        }
        gSearchLat = Double(txtLat.text!) ?? 0.0
        gSearchLon = Double(txtLon.text!) ?? 0.0
        gSearchName = "LatLon"
        gSearchType = "LatLon"
        let place = txtLat.text! + "," + txtLon.text!
        lookupPlace(place: place)
    }
   
    @IBAction func btnCityPress(_ sender: Any) {
        self.view.endEditing(true)
        gCity = txtCity.text!
        gState = txtState.text!
        gSearchLat = 0.0
        gSearchLon = 0.0
        gSearchName = txtCity.text!
        gSearchType = "City"
        let stateCity = txtState.text! + "/" + txtCity.text!
        let place = stateCity.replacingOccurrences(of: " ", with: "_")
        lookupPlace(place: place)
    }

    @IBAction func btnZipPress(_ sender: Any) {
        self.view.endEditing(true)
        let place = txtZip.text!
        if place.count != 5 {
            showError( "Zip must be a 5 digit number!")
            return
        }
        gSearchLat = 0.0
        gSearchLon = 0.0
        gSearchName = "zip: " + place
        gSearchType = "Zip"
        lookupPlace(place: place)
    }
   
    @IBAction func btnNearbyTap(_ sender: Any) {
        self.view.endEditing(true)
        if gUserLat == 0.0 && gUserLon == 0.0 {
            showError("Your location not available")
            return
        }
        gSearchLat = gUserLat
        gSearchLon = gUserLon
        gSearchName = "You"
        gSearchType = "Nearby"
        txtLat.text = formatDbl(number: gUserLat, places: 3)
        txtLon.text = formatDbl(number: gUserLon, places: 3)
        enableButton(btn: btnLatLon, enable: latLonIsValid())
        let place = "\(gUserLat),\(gUserLon)"
        lookupPlace(place: place)
    }

    @IBAction func btnAirportPress(_ sender: Any) {
        self.view.endEditing(true)
        gSearchLat = 0.0
        gSearchLon = 0.0
        gSearchName = txtAirport.text!
        gSearchType = "Station"
        DoAirportCode()
    }

    @IBAction func btnMapTap(_ sender: UIButton) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "idMapVC") as! MapVC

        gMapDidUpdate = false
        navigationController?.pushViewController(vc, animated: true)
    }


    @IBAction func btnSaveTap(_ sender: UIBarButtonItem!) {
        self.view.endEditing(true)
        if selectedStationID == "" {
            showError("You have not selected a weather station")
            return
        }
        gStationID = selectedStationID
        UserDefaults.standard.set(txtCity.text, forKey: "wucity")
        gCity = txtCity.text!
        UserDefaults.standard.set(txtState.text, forKey: "wustate")
        gState = txtState.text!
        UserDefaults.standard.set(txtAirport.text, forKey: "wuStationID")
        gState = txtState.text!
        gDataIsCurrent = false
        print("Saved \(txtAirport.text!)  \(txtCity.text!), \(txtState.text!)")
        print("Saving stationID: \(selectedStationID)")
        guard (navigationController?.popViewController(animated:true)) != nil else {
            print("No navigationController"); return
        }
    }
    
    //MARK: ---- funcs for Buttons ----
    func DoAirportCode() {
        var place = txtAirport.text!
        let n = place.count
        if n < 3 || n > 11 || (n < 8 && n > 4) {
            showError("3 or 4 characters for an airport\nor 8-11 characters for a pws")
            return
        }
        if n>4 {place = "pws:" + place}
        lookupPlace(place: place)
    }
    
    func lookupPlace(place: String) {
        let features = "geolookup"
        Detail = ""
        lblDetail.text = ""
        gStations = []
        infoStations = []
        tableView.reloadData()
        
        //      Make wu URL from "myAPIKey", "features", and "place"
        let urlTuple = makeWuUrlJson(APIKey: gAPIKey, features: features, place: place)
        if urlTuple.errorStr != "" {
            showError(urlTuple.errorStr)
            return
        }
        let url = urlTuple.url
        weatherJSON(url: url)
        
    }
    
    
    //MARK: ---- weatherJSONGet JSON geolookup from wunderground.com ----
    //to make StandAlone - must return myError, globalDictJSON, working? (errShort, errLong)
    //---------------------- weatherJSON func ---------------------
    func weatherJSON(url: URL) {
        let checkLog = tryToLogCall(makeCall: true)
        if !checkLog.isOK { return }
        //------------------------------- task (thread) ------------------------------
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let response = response {
                print ("\n$$$$$$ response $$$$$$\n\(response)\n$$$$$$ end response $$$$$$\n")
            }
            guard error == nil, let dataReturned = data else {
                DispatchQueue.main.async {
                    print("\nweatherJSON Err202: ",error as AnyObject)
                    //printDictionary(dict: error as? [String: AnyObject], expandLevels: 0, dashLen: 0, title: "error")
                    self.lblError.text = "Err202:\(error!)"
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    //self.activityIndicator.stopAnimating()

                    self.lblDetail.text = error.debugDescription
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
            
            var myError = ""
            
            jsonTry: do {
                let jsonResult = try JSONSerialization.jsonObject(with: dataReturned, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                guard let dictJson = jsonResult as? [String: AnyObject] else {  //Try to convert jsonResult to Dictionary
                    myError  = "Err203:Could not convert JSON to Dictionary"
                    print("\n\(myError)")
                    break jsonTry
                }
                //globalDictJSON = dictJson
                printDictionary(dict: dictJson, expandLevels: 0, dashLen: 0, title: "JSON")
                //self.printDictionary(dict: dictJson, expandLevels: 1, dashLen: 0, title: "JSON")

                guard let dictResponse =   dictJson["response"] as? [String: AnyObject] else { //Try to convert jsonResult["response"] to Dictionary
                    myError = "Err204:No 'response' in JSON data"
                    print("\n\(myError)")
                    break jsonTry
                }

                printDictionary(dict: dictResponse, expandLevels: 0, dashLen: 0, title: "Response")

                guard let dictFeatures = dictResponse["features"] as? [String: AnyObject] else { //Try to convert jsonResult.response.features to Dictionary
                    myError = "Err205:No 'features' in JSON 'response' data"
                    print("\n\(myError)")
                    break jsonTry}
                
                errorTry: do {      //See if there is an "error" entry in jsonResult.response
                    guard let dictError = dictResponse["error"] as? [String: AnyObject] else {myError = "";  break errorTry}
                    printDictionary(dict: dictError, expandLevels: 1, dashLen: 0, title: "response.error")
                    myError = "Err210:unknown error"
                    if let err = dictError["type"] as? String { myError = err }
                    if let er = dictError["description"] as? String { myError = er }
                    print("\n\("Err210:" + myError)")
                    break jsonTry
                }// end errorTry
                
                resultsTry: do {    //See if there is a "results" entry in jsonResult.response (suggests other wx stations)
                    guard let oResults = dictResponse["results"] else {myError = "";  break resultsTry}
                    myError = "Place not found."
                    print("\n\(myError)")
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
                
                //MARK: - end of overall JSON, beginning of geolookup -
                //let locOptional = Location(json: dictJson)  // Location struct initialiser
                
                guard let dictLocation = dictJson["location"] as? [String: AnyObject] else {
                    DispatchQueue.main.async {
                        let e = "Err221:Could not get location"
                        print("\n\(e)")
                        self.lblError.text = e
                        //self.activityIndicator.stopAnimating()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }// DispatchQueue.main.async
                    return
                }//end guard else
                
                let loc = Location(loc: dictLocation)
                print("\n\n\(loc)\n")
                //let dictLocation = dictJson["location"] as! [String: AnyObject]
                
                self.zip = loc.zip
                gCity = loc.city
                if loc.type == "CITY" {
                    gState = loc.state
                } else if loc.country_name.count < 10 {
                    gState = loc.country_name
                } else {
                    gState = loc.country
                }
                var latVal = 0.0
                var lonVal = 0.0
                if abs(gSearchLat) < 0.0001 && abs(gSearchLon) < 0.0001 {
                    latVal = Double(loc.lat) ?? 0.0
                    lonVal = Double(loc.lon) ?? 0.0
                    gSearchLat = latVal
                    gSearchLon = lonVal
                    //self.latStr = loc.lat
                    //self.lonStr = loc.lon
                } else {
                    latVal = gSearchLat
                    lonVal = gSearchLon
                }
                self.latStr = formatDbl(number: latVal, places: 3)
                self.lonStr = formatDbl(number: lonVal, places: 3)
                //printDictionary(dict: dictLocation, expandLevels: 0, dashLen: 0, title: "Location")
                //printDictionary(dict: dictLocation, expandLevels: 1, dashLen: 0, title: "Location")
                
                let dictNearby =  dictLocation["nearby_weather_stations"] as![String: AnyObject]
                printDictionary(dict: dictNearby, expandLevels: 0, dashLen: 0, title: "Nearby")
                
                let dictAirport = dictNearby["airport"] as! [String: AnyObject]
                printDictionary(dict: dictAirport, expandLevels: 0, dashLen: 0, title: "Airport")
                let apStationArr = dictAirport["station"] as! [[String: AnyObject]]
                
                let dictApStationA0 = apStationArr.first
                printDictionary(dict: dictApStationA0, expandLevels: 0, dashLen: 0, title: "Airport station[0]")
                //printDictionary(dict: dictApStationA0, expandLevels: 1, dashLen: 0, title: "Airport station[0]")

                print("\n \(apStationArr.count) airport wx stations")
                self.Detail = "  \(apStationArr.count) airport wx stations\n"
                //var stationArr = [String]()
                
                for dictStation in apStationArr {
                    let station = Station(sta: dictStation)
                    gStations.append(station)
                    let stationID = station.id
                    let padID = stationID.padding(toLength: 4, withPad: " ", startingAt: 0)
                    let city = station.city
                    let state = station.state
                    let country = station.country
                    let lat = station.lat
                    let lon = station.lon

                    let tupleDistDir = formatDistDir(latFrom: latVal, lonFrom: lonVal, latTo: lat, lonTo: lon, doMi: true, doDeg: false)
                    let strDistDir = tupleDistDir.strDistDir
                    let strLatLon3 = formatLatLon(lat: lat, lon: lon, places: 3)
                    print(stationID, strLatLon3, country, state, city)
                    let stationItem = "Airport \(stationID) \(strDistDir) \(city)"
                    let stationDetail = "Airport\n" +
                                        "-------\n" +
                                        "\(padID)        \(strLatLon3)  \(strDistDir)\n" +
                                        "\(city), \(state)\n"
                    let infoStation = StationInfo(type: "Airport", id: stationID, distMi: tupleDistDir.dist, dir: tupleDistDir.deg, lineItem: stationItem, detail: stationDetail)
                    self.infoStations.append(infoStation)
                }

                let dictPws = dictNearby["pws"] as! [String: AnyObject]
                let pwsStationArr = dictPws["station"] as! [[String: AnyObject]]
                
                if let dictStationP0 = pwsStationArr.first {
                    printDictionary(dict: dictStationP0, expandLevels: 0, dashLen: 0, title: "Personal station")
                }
                
                print("\n\(pwsStationArr.count) personal wx stations")
                self.Detail += "\n \(pwsStationArr.count) personal wx stations\n"
                for dictStation in pwsStationArr {
                    let station = Station(sta: dictStation)
                    gStations.append(station)
                    let stationID = station.id
                    let padID = stationID.padding(toLength: 11, withPad: " ", startingAt: 0)
                    let neighborhood = station.neighborhood
                    let city = station.city
                    let state = station.state
                    let lat = station.lat
                    let lon = station.lon
                    
                    let tupleDistDir = formatDistDir(latFrom: latVal, lonFrom: lonVal, latTo: lat, lonTo: lon, doMi: true, doDeg: false)
                    let strDistDir = tupleDistDir.strDistDir
//                    var distStr = "     "
//                    let distNM = greatCircDist(ALat: latVal, ALon: lonVal, BLat: lat, BLon: lon)
//                    let distMi = distNM * 1.15
//                    let dirDeg = greatCircAng(ALat: latVal, ALon: lonVal, BLat: lat, BLon: lon, Dist: distNM)
//                    if distMi < 99 { distStr = formatDbl(number: distMi, fieldLen: 5, places: 1) }
//                    let distDirStr = "\(distStr)mi \(dirDeg)°"
                    
                    let strLatLon3 = formatLatLon(lat: lat, lon: lon, places: 3)
                    
                    //let km = dictStation["distance_km"] as? Double ?? -99
                    print (padID, strLatLon3, state, city, neighborhood)
                    //let hood = String(neighborhood.characters.prefix(21)) // first21Chars
                    
                    let stationItem = "pws \(padID) \(strDistDir) \(city)"
                    let stationDetail = "personal wx station\n" +
                        "-------------------\n" +
                        "\(padID) \(strLatLon3)  \(strDistDir)\n" +
                        "\(neighborhood)\n" +
                    "\(city), \(state)\n"
                    let infoStation = StationInfo(type: "pws", id: stationID, distMi: tupleDistDir.dist, dir: tupleDistDir.deg, lineItem: stationItem, detail: stationDetail)
                    self.infoStations.append(infoStation)
                }//next
                
                DispatchQueue.main.async {
                    
                    self.enableButton(btn: self.btnMap, enable: true)
                    
                    self.tableView.reloadData()
                }// DispatchQueue.main.async
                
                //wuFeaturesWithDataArr = wuFeaturesArr
                
            } catch { //jsonTry:do Try/Catch -  (try JSONSerialization.jsonObject) = failed
                myError = "Err208: Can't get JSON data!"
                print("\n\(myError)")
            }//end jsonTry:do Try/Catch
            
            // Success again! We have made it through everything.
            DispatchQueue.main.async {
                self.lblError.text = myError
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //self.activityIndicator.stopAnimating()
                self.txtCity.text = gCity
                self.txtState.text = gState
                self.enableButton(btn: self.btnCity, enable: self.cityStateIsValid())

                self.txtZip.text = self.zip
                self.enableButton(btn: self.btnZip, enable: self.zipIsValid())
                self.txtLat.text = self.latStr
                self.txtLon.text = self.lonStr
                self.enableButton(btn: self.btnLatLon, enable: self.latLonIsValid())
                self.lblDetail.text = self.Detail
            }// DispatchQueue.main.async
            
        } //----------------------------- end task (thread) -----------------------------------
        
        //self.activityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        task.resume()
        return
    }//end func weatherJSON
    //MARK: ---- end of weatherJSON -----
    
    func showError(_ message: String) {
        showAlert(title: "Error", message: message)
    }
    
    func showAlert(title: String = "Error", message: String, closeMsg: String = "OK") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: closeMsg, style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }

    // ------ Enable/Disable a Button and change its backgroundColor between  colorButtonNorm & colorButtonGray ------
    func enableButton(btn: UIButton, enable: Bool) {
        btn.isEnabled = enable                                              // enable/disable
        btn.backgroundColor = enable ? colorButtonNorm : colorButtonGray    //blue=(0x007AFF) or gray
    }
    
    func zipIsValid() -> Bool {
        let zip = txtZip.text!
        if zip.count != 5 {return false}
        if Int(zip) != nil {return true}
        return false
    }
    
    func stationIsValid() -> Bool {
        let sta = txtAirport.text!
        let n = sta.count
        if n < 3 || ( n > 4 && n < 8) || n > 11 {return false}
        return true
    }

    func cityStateIsValid() -> Bool {
        if txtCity.text!.count < 2 {return false}
        if txtState.text!.count < 2 {return false}
        return true
    }
    
    func latLonIsValid() -> Bool {
        var txt = ""
        txt  = txtLat.text!
        if txt.count < 2 {return false}
        guard let lat = Double(txt) else {return false}
        if lat < -90.0 || lat > 90.0 {return false}
        
        txt  = txtLon.text!
        if txt.count < 2 {return false}
        guard let lon = Double(txt) else {return false}
        if lon < -180.0 || lon > 180.0 {return false}
        return true
    }
    
}//end class

//MARK: ================== TableView Extension =======================

extension GeoLookup_ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return gStations.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { // Default is 1 if not implemented
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        
        cell.textLabel?.font = UIFont.init(name: "menlo", size: 14)
        cell.textLabel?.text = infoStations[indexPath.row].lineItem
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStationID = gStations[indexPath.row].id
        txtAirport.text = selectedStationID
        enableButton(btn: btnStation, enable: stationIsValid())
        lblDetail.text = infoStations[indexPath.row].detail
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? { // return list of section titles to display in section index view (e.g. "ABCD...Z#")
        return nil
    }
}//end extension
