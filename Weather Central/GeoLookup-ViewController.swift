//
//  GeoLookup-ViewController.swift
//  Weather Central
//
//  Created by George Bauer on 9/28/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import UIKit
import CoreLocation

//MARK:---- Globals for MapVC ----
// Back & forth to Homepage
var gSearchLat  = 0.0
var gSearchLon  = 0.0

class GeoLookup_ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MapDelegate {
                                                                                                    //delegate
    //MARK: ---- my vars ----
    var WuDownloadDone = false
    var Detail = ""
    var selectedStationID = ""
    var infoStations = [StationInfo]()
    var cityState = ""
    var zip = ""
    var stationID = ""
    var latStr = "?"
    var lonStr = "?"
    var stations   = [Station]()
    var searchType = LocationSelectionType.none    // set by: Home, Geolookup;  used by: Home, Geolookup, Map
    var lastSearch = ""
    var searchName = ""                            // set by: Geolookup;        used by: Map

    var locationManager = CLLocationManager()
    var userLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    //var userLat: Double = 0
    //var userLon: Double = 0
    //MARK: ---- IBOutlet's ----
    @IBOutlet weak var tableView:  UITableView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var txtCity:    UITextField!
    @IBOutlet weak var txtLat:     UITextField!
    @IBOutlet weak var txtLon:     UITextField!
    @IBOutlet weak var txtZip:     UITextField!
    @IBOutlet weak var txtStation: UITextField!

    @IBOutlet weak var lblError:   UILabel!
    @IBOutlet weak var lblDetail:  UILabel!

    @IBOutlet weak var btnCity: UIButton!
    @IBOutlet weak var btnLatLon: UIButton!
    @IBOutlet weak var btnStation: UIButton!
    @IBOutlet weak var btnZip: UIButton!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnMap: UIButton!

    //MARK: ---- iOS built-in functions & overrides ----
    
    // When GeoLookup loads:
    // If there is search text (not "local:") from Homepage, load the pertainent textfield, and clear the others.
    //          lastSearch, searchType
    //          txtCity, txtLat, txtLon ,txtStation, txtZip
    // If a download had been done on Home since we were here last, load all textfields except Station
    // and also set gSearchLat,gSearchLon,searchName?
    // If not, remember the previous state from Geolookup, and restore it.
    // On exit to Home, save the StationID, or if none save last search item.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)

        self.activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)   // make My activityIndicator bigger
        UIApplication.shared.isNetworkActivityIndicatorVisible = false          // turn-off System activityIndicator
        self.activityIndicator.stopAnimating()                                  // turn-off My activityIndicator
        // Default Map Settings - Show local map
        gSearchLat  = gUserLat
        gSearchLon  = gUserLon
        searchName = "You"
        searchType = .near     // deault

        // Start process to update user location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        enableButton(btn: btnMap, enable: true)

        // Get City, State, Station from permanent storage & set button states
        let searchTypeStr = UserDefaults.standard.object(forKey: UDKey.searchType) as? String ?? "none"
        searchType = LocationSelectionType(rawValue: searchTypeStr) ?? LocationSelectionType.none
        lastSearch   = UserDefaults.standard.object(forKey: UDKey.lastSearch) as? String ?? ""
        cityState    = UserDefaults.standard.object(forKey: UDKey.cityState)  as? String ?? ""
        zip          = UserDefaults.standard.object(forKey: UDKey.zip)        as? String ?? ""
        stationID    = UserDefaults.standard.object(forKey: UDKey.station)    as? String ?? ""
        txtCity.text = cityState
        enableButton(btn: self.btnCity, enable: isCityStateValid(txtCity.text!))
        txtZip.text = zip
        enableButton(btn: self.btnZip,  enable: isZipValid(txtZip.text!))
        print("GeoLookup.viewDidLoad got   searchType = \(searchType)   LsstSearch = \(lastSearch)")
        txtStation.text = stationID
        enableButton(btn: btnStation,   enable: isStationValid(stationID))
        if searchType == .latlon {
            let LLtuple = decodeLL(latLonTxt: lastSearch)
            if LLtuple.errorLL.isEmpty {
                txtLat.text = "\(LLtuple.lat)"
                txtLon.text = "\(LLtuple.lon)"
                //gLat = UserDefaults.standard.object(forKey: UDKey.lat)              as? Double ?? 0.0
                //gLon = UserDefaults.standard.object(forKey: UDKey.lon)              as? Double ?? 0.0
                enableButton(btn: btnLatLon, enable: true)
            } else {
                enableButton(btn: btnLatLon, enable: false)
            }
        }
        // Clean out the Stations arrays & clear the TableView
        stations = []
        infoStations = []
        tableView.reloadData()

        lblError.text = ""
        lblDetail.text = "Find the weather station you want, then tap \"Save\" to use it for your query."

    }

    override func viewWillAppear(_ animated: Bool) {
    }

    override func viewDidAppear(_ animated: Bool) {
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segueID = \(segue.identifier ?? "No ID!")")
        guard let thisSegueID = segue.identifier else { return }
        switch thisSegueID {
        case segueID.GeoLookupToMap:
            print("Goin to the Map!!")
            let mapVC = segue.destination as! MapVC
            mapVC.searchLat = gSearchLat
            mapVC.searchLon = gSearchLon
            mapVC.searchType = searchType
            mapVC.searchName = searchName
            mapVC.latDelta = 0.18
            mapVC.lonDelta = 0.18
            mapVC.stations = stations
            mapVC.delegate = self               //delegate

        default:
            print("segueID = \(segue.identifier ?? "No ID!")")
        }
    }

    //delegate  - MapDelegate required method
    func mapReturn(returnType: LocationSelectionType, stationID: String, lat: Double, lon: Double) {   //delegate
        switch returnType {
        case .latlon:
            print("😃😃😃😃Update Map to \(lat), \(lon)😃😃😃😃")
            searchType = returnType
            txtLat.text = formatDbl(number: lat, places: 3)
            txtLon.text = formatDbl(number: lon, places: 3)
            lastSearch = txtLat.text! + "," + txtLon.text!
            enableButton(btn: btnLatLon, enable: true)
        case .station:
            print("😃😃Update Map to \(stationID)😃😃")
            searchType = returnType
            txtStation.text = stationID
            lastSearch = stationID
            enableButton(btn: btnStation, enable: true)
        default: break
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
            lookupStation()
        }
        return true
    }

    //MARK: ---- IBAction's ----

    // txtCity Editing Change
    @IBAction func txtCityChanged(_ sender: UITextField) {
        enableButton(btn: btnCity, enable: isCityStateValid(txtCity.text!))
    }

    // txtCity Editing Ended
    @IBAction func txtCityEditEnd(_ sender: UITextField) {
        print("txtCityEditEnd")
        var str = txtCity.text!.trim()
        var state = ""
        if !isCityStateValid(txtCity.text!) {
            str = str.replacingOccurrences(of: "  ", with: " ")
            //let sp1 = str.indexOf(searchforStr: " ")
            let sp2 = str.indexOfRev(searchforStr: " ")
            if sp2 <= 0 { return }
            state =  str.mid(begin: sp2 + 1)
            if state.count == 2 { state = state.uppercased() }
            str = str.left(sp2) + "," + state
            enableButton(btn: btnCity, enable: isCityStateValid(str))
        }//endif
        let pComma = str.indexOf(searchforStr: ",")
        state =  str.mid(begin: pComma + 1)
        if state.count == 2 { state = state.uppercased() }
        str = str.left(pComma + 1) + state
        txtCity.text = str
    }

    @IBAction func txtLatChanged(_ sender: UITextField) {
        enableButton(btn: btnLatLon, enable: isLatValid(latTxt: txtLat.text!) && isLonValid(lonTxt: txtLon.text!)  )
    }
    @IBAction func txtLonChanged(_ sender: UITextField) {
        enableButton(btn: btnLatLon, enable: isLatValid(latTxt: txtLat.text!) && isLonValid(lonTxt: txtLon.text!)  )
    }
    
    //---- Limit Station Codes to 11 characters ----
    @IBAction func txtStationChanged(_ sender: Any) {
        let text = txtStation.text!
        let nChars = text.count
        lblError.text = ""
        if nChars > 11 {
            lblError.text = "No more than 11 characters allowed."
            txtStation.deleteBackward()
        }
        enableButton(btn: btnStation, enable: isStationValid(text))
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
            if !isStringAnInt(txtZip.text!) {
                lblError.text = "Zip must be a number."
                txtZip.deleteBackward()
            }
        }
        enableButton(btn: btnZip, enable: isZipValid(txtZip.text!))
    }
    
    //MARK: ---------- Button Actions ----------
    @IBAction func btnLatLonPress(_ sender: Any) {
        let latTxt = txtLat.text!
        let lonTxt = txtLon.text!
        if lonTxt == "" || lonTxt == "" {showError("You must fill in both\nLatitude and Longitude")}
        if !isLatValid(latTxt: latTxt) {
            showError("\(latTxt) is not a legal Latitude.")
            return
        }
        if !isLonValid(lonTxt: lonTxt) {
            showError("\(lonTxt) is not a legal Longitude.")
            return
        }
        self.view.endEditing(true)
        lastSearch = latTxt + "," + lonTxt
        stationID = ""
        txtStation.text = stationID
        gSearchLat = Double(txtLat.text!) ?? 0.0
        gSearchLon = Double(txtLon.text!) ?? 0.0
        searchName = "LatLon"
        searchType = .latlon
        let place = txtLat.text! + "," + txtLon.text!
        lookupPlace(place: place)
    }
   
    @IBAction func btnCityPress(_ sender: Any) {
        if !isCityStateValid(txtCity.text!) {
            showError("You must supply City and State, separated by a comma.")
            return
        }
        self.view.endEditing(true)
        cityState = txtCity.text!
        gSearchLat = 0.0
        gSearchLon = 0.0
        stationID = ""
        txtStation.text = stationID
        searchName = txtCity.text!
        searchType = .city
        lastSearch = txtCity.text!
        let splitCityState = cityState.components(separatedBy: ",")
        let city =  splitCityState[0].trim()
        let state = splitCityState[1].trim()
        let stateCity = state + "/" + city
        let place = stateCity.replacingOccurrences(of: " ", with: "_")
        lookupPlace(place: place)
    }

    @IBAction func btnZipPress(_ sender: Any) {
        let place = txtZip.text!
        if place.count != 5 {
            showError( "Zip must be a 5 digit number!")
            return
        }
        self.view.endEditing(true)
        stationID = ""
        txtStation.text = stationID
        searchName = "zip: " + place
        searchType = .zip
        lastSearch = txtZip.text!
        lookupPlace(place: place)
    }
   
    @IBAction func btnNearbyTap(_ sender: Any) {
        self.view.endEditing(true)
        if gUserLat == 0.0 && gUserLon == 0.0 {
            showError("Your location not available")
            return
        }
        stationID = ""
        txtStation.text = stationID
        gSearchLat = gUserLat
        gSearchLon = gUserLon
        searchName = "You"
        searchType = .near
        lastSearch = "local"
        txtLat.text = formatDbl(number: gUserLat, places: 3)
        txtLon.text = formatDbl(number: gUserLon, places: 3)
        enableButton(btn: btnLatLon, enable: isLatValid(latTxt: txtLat.text!) && isLonValid(lonTxt: txtLon.text!) )
        let place = "\(gUserLat),\(gUserLon)"
        lastSearch = place
        lookupPlace(place: place)
    }

    @IBAction func btnStationTap(_ sender: Any) {
        self.view.endEditing(true)
        gSearchLat = 0.0
        gSearchLon = 0.0
        searchName = txtStation.text!
        searchType = .station
        lastSearch = txtStation.text!
        lookupStation()
    }

    @IBAction func btnMapTap(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "idMapVC") as! MapVC
//        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func btnSaveTap(_ sender: UIBarButtonItem!) {
        self.view.endEditing(true)
//        if selectedStationID == "" {
//            showError("You have not selected a weather station")
//            return
//        }
        UserDefaults.standard.set(searchType.rawValue, forKey: UDKey.searchType)
        UserDefaults.standard.set(cityState,      forKey: UDKey.cityState)
        UserDefaults.standard.set(txtStation.text, forKey: UDKey.station)
        UserDefaults.standard.set(lastSearch,     forKey: UDKey.lastSearch)
        gDataIsCurrent = false
        print("GeoLookup saved searchType \(searchType.rawValue)")
        print("GeoLookup saved lastSearch \(lastSearch)")
        print("GeoLookup saved cityState  \(cityState)")
        print("GeoLookup saved station    \(stationID)")
        guard (navigationController?.popViewController(animated:true)) != nil else {
            print("No navigationController"); return
        }
    }
    
    //MARK: ---- funcs for Buttons ----
    func lookupStation() {
        var place = txtStation.text!
        let n = place.count
        if n < 3 || n > 11 || (n < 5 && n > 4) {
            showError("3 or 4 characters for an airport or 5-11 characters for a pws")
            return
        }
        if n>4 {place = "pws:" + place}
        lookupPlace(place: place)
    }
    
    func lookupPlace(place: String) {
        let features = "geolookup"
        Detail = ""
        lblDetail.text = ""
        stations = []
        infoStations = []
        tableView.reloadData()
        
        //      Make wu URL from "myAPIKey", "features", and "place"
        let urlTuple = makeWuUrlJson(APIKey: gAPIKey, features: features, place: place)
        if urlTuple.errorStr != "" {
            showError(urlTuple.errorStr)
            return
        }
        let url = urlTuple.url
        startWuDownload(wuURL: url)
        //weatherJSON(url: url)
        
    }
    
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
    
}//end class

//MARK: =================== TableView Extension =======================
extension GeoLookup_ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return stations.count
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
        let selStation =  stations[indexPath.row]
        selectedStationID = selStation.id
        txtStation.text = selectedStationID
        txtZip.text = ""
        txtCity.text = selStation.city + "," + selStation.state
        txtLat.text = "\(formatDbl(number: selStation.lat, places: 3))"
        txtLon.text = "\(formatDbl(number: selStation.lon, places: 3))"
        enableButton(btn: btnStation, enable: isStationValid(selectedStationID))
        lblDetail.text = infoStations[indexPath.row].detail
        lastSearch = selectedStationID
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? { // return list of section titles to display in section index view (e.g. "ABCD...Z#")
        return nil
    }
}//end extension

//MARK: =================== WuAPIdelegate Extension =======================
extension GeoLookup_ViewController: WuAPIdelegate {      //delegate <— (4)

    //This function is called your download request
    func startWuDownload(wuURL: URL) {
        WuDownloadDone = false
        lblError.text = "...downloading"       // change this label, start activityIndicators
        self.activityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        wuAPI.delegate = self                   //delegate <— (5)
        wuAPI.downloadData(url: wuURL)
        return
    }//end func

    func downloadDone(isOK: Bool, numFeaturesRequested: Int,  numFeaturesReceived: Int, errStr: String){    //delegate (6)
        DispatchQueue.main.async {
            print("GeoLookup downloadDone delegate reached:")
            print("errStr = \(errStr)")
            let es = isOK ? "" : "\(errStr)\n"
            let msg = "isOK = \(isOK)\n\(es)\(numFeaturesRequested) features requested, \(numFeaturesReceived) received."
            print(msg)

            //----------------------------
            //process your data
            self.lblError.text = msg           // change this label, stop activityIndicators
            UIApplication.shared.isNetworkActivityIndicatorVisible = false  // turn-off built-in activityIndicator
            self.activityIndicator.stopAnimating()                          // turn-off My activityIndicator

            if !isOK {
                self.showAlert(title: "Fail", message: "\(errStr)")
                return
            }

            //self.showAlert(title: "Success", message: "APIKey updated to \(self.APItxt)")
            if !gGeoLookup.hasData {
                self.showAlert(title: "Fail", message: "No Geolookup data in download!")
                return
            }
            let dictLocation =  gGeoLookup.data[0]
            printDictionary(dict: dictLocation, expandLevels: 0, dashLen: 7, title: "gGeolookup")

            let loc = Location(loc: dictLocation)
            print("\n\n\(loc)\n")
            //let dictLocation = dictJson["location"] as! [String: AnyObject]

            self.zip = loc.zip
            self.cityState = loc.city
            var state = ""
            if loc.type == "CITY" {
                state = loc.state
            } else if loc.country_name.count < 10 {
                state = loc.country_name
            } else {
                state = loc.country
            }
            if state != "" { self.cityState = self.cityState + "," + state }

            var latVal = 0.0
            var lonVal = 0.0
            if self.searchType != .latlon {
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
                self.stations.append(station)
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
                self.stations.append(station)
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
                self.tableView.reloadData()
            }// DispatchQueue.main.async

        // Success again! We have made it through everything.
            //self.lblError.text = myError
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activityIndicator.stopAnimating()

            self.txtCity.text = self.cityState
            self.enableButton(btn: self.btnCity, enable: isCityStateValid(self.cityState))

            self.txtZip.text = self.zip
            self.enableButton(btn: self.btnZip, enable: isZipValid(self.zip))
            self.txtLat.text = self.latStr
            self.txtLon.text = self.lonStr
            self.enableButton(btn: self.btnLatLon, enable: isLatValid(latTxt: self.latStr) && isLonValid(lonTxt: self.lonStr) )
            self.lblDetail.text = self.Detail

        }//end DispatchQueue
    }//end func
}//end extension


