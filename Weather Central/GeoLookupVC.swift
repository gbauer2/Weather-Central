//
//  GeoLookupVC.swift
//  Weather Central
//
//  Created by George Bauer on 9/28/17.
//  Copyright © 2017-2020 GeorgeBauer. All rights reserved.
//

import UIKit
import CoreLocation

//MARK:---- Globals for MapVC ----
// Back & forth to Homepage
var gSearchLat  = 0.0
var gSearchLon  = 0.0

class GeoLookupVC: UIViewController {

    //MARK: -- Instance vars --
    let codeFile = "GeoLookupVC"
    var wuDownloadDone = false
    var detail = ""
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
    var latDelta = 0.25
    var lonDelta = 0.25

    var locationManager = CLLocationManager()
    var userLocation = CLLocation(latitude: 28.5, longitude: -81.55)
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

    //MARK: ---- Overrides ----
    
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

        // NotificationCenter Observer (Listener)
        NotificationCenter.default.addObserver(self, selector: #selector(self.wuDownloadDoneNotification), name: NSNotification.Name(rawValue: NotificationCenterKey.wuDownloadDone), object: nil)

        self.activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)   // make My activityIndicator bigger
        UIApplication.shared.isNetworkActivityIndicatorVisible = false          // turn-off System activityIndicator
        self.activityIndicator.stopAnimating()                                  // turn-off My activityIndicator
        // Default Map Settings - Show local map
        gSearchLat  = gUserLat
        gSearchLon  = gUserLon
        searchName = "You"
        searchType = .near     // default

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
        print("🙂 \(codeFile)#\(#line) viewDidLoad got   searchType = \(searchType)   LastSearch = \(lastSearch)")

        txtCity.text = cityState
        enableButton(btn: self.btnCity, enable: isCityStateValid(txtCity.text))

        txtZip.text = zip
        enableButton(btn: self.btnZip,  enable: isZipValid(txtZip.text))

        txtStation.text = stationID
        enableButton(btn: btnStation,   enable: isStationValid(stationID))

        txtLat.text = ""
        txtLon.text = ""
        enableButton(btn: btnLatLon, enable: false)

        if searchType == .latlon {
            let latLonTuple = decodeLL(latLonTxt: lastSearch)
            if latLonTuple.errorLL.isEmpty {
                txtLat.text = "\(latLonTuple.lat)"
                txtLon.text = "\(latLonTuple.lon)"
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
        print("🙂 \(codeFile)#\(#line) segueID = \(segue.identifier ?? "⛔️ No ID! ⛔️")")
        guard let thisSegueID = segue.identifier else { return }
        switch thisSegueID {
        case SegueID.geoLookupToMap:
            print("🙂 \(codeFile)#\(#line) Goin to the Map!!")
            if gSearchLat == 0.0 && gSearchLon == 0.0 {
                gSearchLat = 40
                gSearchLon = -95
                latDelta = 35
                lonDelta = 55
            }
            let mapVC = segue.destination as! MapVC
            mapVC.searchLat = gSearchLat    // 0
            mapVC.searchLon = gSearchLon    // 0
            mapVC.searchType = searchType   // .latlon
            mapVC.searchName = searchName   // "You"
            mapVC.latDelta = latDelta       // .25
            mapVC.lonDelta = lonDelta       // .25
            mapVC.stations = stations       //  empty
            mapVC.delegate = self           //delegate

        default:
            print("⛔️ \(codeFile)#\(#line) segueID = \(segue.identifier ?? "No ID!")")
        }
    }

    //---- NotificationCenter -  wuDownloadDone Notification ----
    @objc func wuDownloadDoneNotification() {
        print("\n😃😡😃😡 \(codeFile)#\(#line) Got the wuDownloadDone Notification😃😡😃😡\n")
        lblError.text = "got the wuDownloadDone Notification"
    }

    // ------ Dismiss Keybooard if user taps empty area ------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: ---- IBAction's ----

    // txtCity Editing Change
    @IBAction func txtCityChanged(_ sender: UITextField) {
        enableButton(btn: btnCity, enable: isCityStateValid(txtCity.text))
    }

    // txtCity Editing Ended
    @IBAction func txtCityEditEnd(_ sender: UITextField) {
        print("🙂 \(codeFile)#\(#line) txtCityEditEnd")
        var str = txtCity.text?.trim ?? ""
        var state = ""
        if !isCityStateValid(txtCity.text) {
            str = str.replacingOccurrences(of: "  ", with: " ")
            //let sp1 = str.indexOf(searchforStr: " ")
            let sp2 = str.lastIntIndexOf(" ")
            if sp2 <= 0 { return }
            state =  str.substring(begin: sp2 + 1)
            if state.count == 2 { state = state.uppercased() }
            str = str.left(sp2) + "," + state
            enableButton(btn: btnCity, enable: isCityStateValid(str))
        }//endif
        let pComma = str.firstIntIndexOf(",")
        state =  str.substring(begin: pComma + 1)
        if state.count == 2 { state = state.uppercased() }
        str = str.left(pComma + 1) + state
        txtCity.text = str
    }

    @IBAction func txtLatChanged(_ sender: UITextField) {

        let allowedCharacters = CharacterSet.init(charactersIn: "0123456789.°").inverted

        txtLat.text = txtLat.text?.left(10).uppercased()
        latStr = txtLat.text ?? ""
        if latStr.isEmpty { return }
        var prefix = latStr.left(1)
        if prefix == "-" {
            prefix = "S"
        }
        if prefix == "N" || prefix == "S" {
            latStr = latStr.substring(begin: 1, length: 0)    // 
        } else {
            prefix = "N"
        }
        //let characterSet = CharacterSet(charactersIn: latStr)
        //return allowedCharacters.isSuperset(of: characterSet)

        let compSepByCharInSet = latStr.components(separatedBy: allowedCharacters)
        let latFiltered = compSepByCharInSet.joined(separator: "")
        txtLat.text = prefix + latFiltered

        enableButton(btn: btnLatLon, enable: isLatValid(txtLat.text) && isLonValid(txtLon.text)  )
    }
    @IBAction func txtLonChanged(_ sender: UITextField) {

        let allowedCharacters = CharacterSet.init(charactersIn: "-0123456789.EW°").inverted

        txtLon.text = txtLon.text?.left(11).uppercased()
        lonStr = txtLon.text ?? ""
        if lonStr.isEmpty { return }
        var prefix = lonStr.left(1)

        if prefix == "-" {
            prefix = "W"
        }
        if prefix == "W" || prefix == "E" {
            lonStr = lonStr.substring(begin: 1, length: 0)
        } else {
            prefix = "E"
        }

        let compSepByCharInSet = lonStr.components(separatedBy: allowedCharacters)
        let lonFiltered = compSepByCharInSet.joined(separator: "")
        txtLon.text = prefix + lonFiltered

        enableButton(btn: btnLatLon, enable: isLatValid(txtLat.text) && isLonValid(txtLon.text)  )
    }
    
    //---- Limit Station Codes to 11 characters ----
    @IBAction func txtStationChanged(_ sender: Any) {
        let text = txtStation.text ?? ""
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
        let text = txtZip.text ?? ""
        let nChars = text.count
        lblError.text = ""
        if nChars > 0 {
            if nChars > 5 {
                lblError.text = "Only a 5-digit zip allowed."
                txtZip.deleteBackward()
            }
            if !isStringAnInt(txtZip.text ?? "") {
                lblError.text = "Zip must be a number."
                txtZip.deleteBackward()
            }
        }
        enableButton(btn: btnZip, enable: isZipValid(txtZip.text))
    }
    
    //MARK: ---------- Button Actions ----------
    @IBAction func btnLatLonPress(_ sender: Any) {
        let latTxt = txtLat.text ?? ""
        let lonTxt = txtLon.text ?? ""
        if lonTxt == "" || lonTxt == "" {showError("You must fill in both\nLatitude and Longitude")}
        if !isLatValid(latTxt) {
            showError("\(latTxt) is not a legal Latitude.")
            return
        }
        if !isLonValid(lonTxt) {
            showError("\(lonTxt) is not a legal Longitude.")
            return
        }
        self.view.endEditing(true)
        lastSearch = latTxt + "," + lonTxt
        stationID = ""
        txtStation.text = stationID
        gSearchLat = getLat(txtLat.text ?? "") ?? 0.0
        gSearchLon = getLon(txtLon.text ?? "") ?? 0.0
        searchName = "LatLon"
        searchType = .latlon
        let place = "\(gSearchLat),\(gSearchLon)"
        //let place = txtLat.text! + "," + txtLon.text!
        lookupPlace(place: place)
    }
   
    @IBAction func btnCityPress(_ sender: Any) {
        if !isCityStateValid(txtCity.text) {
            showError("You must supply City and State, separated by a comma.")
            return
        }
        self.view.endEditing(true)
        cityState = txtCity.text ?? ""
        gSearchLat = 0.0
        gSearchLon = 0.0
        stationID = ""
        txtStation.text = stationID
        searchName = txtCity.text ?? "??"
        searchType = .city
        lastSearch = txtCity.text ?? ""
        let splitCityState = cityState.components(separatedBy: ",")
        let city =  splitCityState[0].trim
        let state = splitCityState[1].trim
        let stateCity = state + "/" + city
        let place = stateCity.replacingOccurrences(of: " ", with: "_")
        lookupPlace(place: place)
    }

    @IBAction func btnZipPress(_ sender: Any) {
        let place = txtZip.text ?? ""
        if place.count != 5 {
            showError( "Zip must be a 5 digit number!")
            return
        }
        self.view.endEditing(true)
        stationID = ""
        txtStation.text = stationID
        searchName = "zip: " + place
        searchType = .zip
        lastSearch = txtZip.text ?? ""
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
        txtLat.text = gUserLat.format(fmt: ".3")
        txtLon.text = gUserLon.format(fmt: ".3")
        enableButton(btn: btnLatLon, enable: isLatValid(txtLat.text) && isLonValid(txtLon.text) )
        let place = "\(gUserLat),\(gUserLon)"
        lastSearch = place
        lookupPlace(place: place)
    }

    @IBAction func btnStationTap(_ sender: Any) {
        self.view.endEditing(true)
        gSearchLat = 0.0
        gSearchLon = 0.0
        searchName = txtStation.text ?? "??"
        searchType = .station
        lastSearch = txtStation.text ?? "??"
        lookupStation()
    }

    @IBAction func btnMapTap(_ sender: UIButton) {
// Segue to Map.  See prepare(for segue
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "idMapVC") as! MapVC
//        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func btnSaveTap(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
//        if selectedStationID == "" {
//            showError("You have not selected a weather station")
//            return
//        }
        UserDefaults.standard.set(searchType.rawValue, forKey: UDKey.searchType)
        UserDefaults.standard.set(cityState,           forKey: UDKey.cityState)
        UserDefaults.standard.set(txtStation.text,     forKey: UDKey.station)
        UserDefaults.standard.set(lastSearch,          forKey: UDKey.lastSearch)
        gDataIsCurrent = false
        print("🙂 \(codeFile)#\(#line) saved searchType \(searchType.rawValue)")
        print("🙂 \(codeFile)#\(#line) saved lastSearch \(lastSearch)")
        print("🙂 \(codeFile)#\(#line) saved cityState  \(cityState)")
        print("🙂 \(codeFile)#\(#line) saved station    \(stationID)")
        guard (navigationController?.popViewController(animated:true)) != nil else {
            print("⛔️ \(codeFile)#\(#line) No navigationController")
            return
        }
    }
    
    //MARK: --- funcs for Buttons ---
    func lookupStation() {
        var place = txtStation.text ?? ""
        let count = place.count
        if count < 3 || count > 11 || (count < 5 && count > 4) {
            showError("3 or 4 characters for an airport or 5-11 characters for a pws")
            return
        }
        if count>4 {place = "pws:" + place}
        lookupPlace(place: place)
    }
    
    func lookupPlace(place: String) {
        detail = ""
        lblDetail.text = ""
        stations = []
        infoStations = []
        tableView.reloadData()
        let features = "geolookup"      // ????? Maybe we might as well get all the standard features while we're at it.

        //      Make wu URL from "myAPIKey", "features", and "place"
        let urlTuple = makeWuUrlJson(wuAPIKey: gAPIKey, features: features, place: place)
        if urlTuple.errorStr != "" {
            showError(urlTuple.errorStr)
            return
        }
        let url = urlTuple.url
        startWuDownload(wuURL: url, place: place)
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



//MARK:- TableView Extension
extension GeoLookupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return stations.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { // Default is 1 if not implemented
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        
        cell.textLabel?.font = UIFont.init(name: "menlo", size: 14)
        cell.textLabel?.text = infoStations[indexPath.row].lineItem
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selStation = stations[indexPath.row]
        selectedStationID = selStation.id
        txtStation.text   = selectedStationID
        txtZip.text       = ""
        txtCity.text      = selStation.city + "," + selStation.state
        txtLat.text       = selStation.lat.format(fmt: ".3")
        txtLon.text       = selStation.lon.format(fmt: ".3")
        enableButton(btn: btnStation, enable: isStationValid(selectedStationID))
        lblDetail.text = infoStations[indexPath.row].detail
        lastSearch = selectedStationID
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? { // return list of section titles to display in section index view (e.g. "ABCD...Z#")
        return nil
    }
}//end extension



//MARK:- WuAPIdelegate Extension
extension GeoLookupVC: WuAPIdelegate {
    //delegate <— (4)

    //This function is called your download request
    func startWuDownload(wuURL: URL, place: String) {
        wuDownloadDone = false
        lblError.text = "...downloading"       // change this label, start activityIndicators
        self.activityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        wuAPI.delegate = self                   //delegate <— (5)
        wuAPI.downloadData(url: wuURL, place: place)
        return
    }//end func

    // ------ All the download data has been placed in the global Features variables ------
    func wuAPIdownloadDone(_ controller: WuAPI, isOK: Bool, numFeaturesRequested: Int,  numFeaturesReceived: Int, errStr: String){    //delegate (6)
        DispatchQueue.main.async {
            print("🙂 \(self.codeFile)#\(#line)  downloadDone delegate reached:")
            print("    errStr = \(errStr)")
            let es = isOK ? "" : "\(errStr)\n"
            let msg = "🙂 \(self.codeFile)#\(#line) isOK = \(isOK)\n\(es)\(numFeaturesRequested) features requested, \(numFeaturesReceived) received."
            print(msg)

            //----------------------------
            //process your data
            UIApplication.shared.isNetworkActivityIndicatorVisible = false  // turn-off built-in activityIndicator
            self.activityIndicator.stopAnimating()                          // turn-off My activityIndicator

            if !isOK {
                self.lblError.text = msg           // change this label, stop activityIndicators
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
            print("\n\n🙂 \(self.codeFile)#\(#line) \(loc)\n")
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
            self.latStr = latVal.format(fmt: ".3")
            self.lonStr = lonVal.format(fmt: ".3")
            //printDictionary(dict: dictLocation, expandLevels: 0, dashLen: 0, title: "Location")
            //printDictionary(dict: dictLocation, expandLevels: 1, dashLen: 0, title: "Location")

            let dictNearby = dictLocation["nearby_weather_stations"] as! [String: AnyObject]
            printDictionary(dict: dictNearby, expandLevels: 0, dashLen: 0, title: "Nearby")

            let dictAirport = dictNearby["airport"] as! [String: AnyObject]
            printDictionary(dict: dictAirport, expandLevels: 0, dashLen: 0, title: "Airport")
            let apStationArr = dictAirport["station"] as! [[String: AnyObject]]

            let dictApStationA0 = apStationArr.first
            printDictionary(dict: dictApStationA0, expandLevels: 0, dashLen: 0, title: "Airport station[0]")
            //printDictionary(dict: dictApStationA0, expandLevels: 1, dashLen: 0, title: "Airport station[0]")

            print("\n🙂 \(self.codeFile)#\(#line)  \(apStationArr.count) airport wx stations")
            self.detail = "  \(apStationArr.count) airport wx stations\n"
            //var stationArr = [String]()
            var closestAirportLat = 9.9
            var closestAirportLon = 9.9

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
                let latDif = abs(lat - gSearchLat)
                let lonDif = abs(lon - gSearchLon)
                closestAirportLat = min(latDif, closestAirportLat)
                closestAirportLon = min(lonDif, closestAirportLon)
                let tupleDistDir = formatDistDir(latFrom: latVal, lonFrom: lonVal, latTo: lat, lonTo: lon, doMi: true, doDeg: false)
                let strDistDir = tupleDistDir.strDistDir
                let strLatLon3 = formatLatLon(lat: lat, lon: lon, places: 3)
                print("🙂 \(self.codeFile)#\(#line) ")
                print(" ",stationID, strLatLon3, country, state, city)
                let stationItem = "Airport \(stationID) \(strDistDir) \(city)"
                let stationDetail = "Airport\n" +
                    "-------\n" +
                    "\(padID)        \(strLatLon3)  \(strDistDir)\n" +
                "\(city), \(state)\n"
                let infoStation = StationInfo(type: "Airport", id: stationID, distMi: tupleDistDir.dist, dir: tupleDistDir.deg, lineItem: stationItem, detail: stationDetail)
                self.infoStations.append(infoStation)
            }
            print("🙂 \(self.codeFile)#\(#line) Closest Airport: \(closestAirportLat),\(closestAirportLon)")
            let dictPws = dictNearby["pws"] as! [String: AnyObject]
            let pwsStationArr = dictPws["station"] as! [[String: AnyObject]]

            if let dictStationP0 = pwsStationArr.first {
                printDictionary(dict: dictStationP0, expandLevels: 0, dashLen: 0, title: "Personal station")
            }

            print("\n🙂 \(self.codeFile)#\(#line) \(pwsStationArr.count) personal wx stations")
            self.detail += "\n \(pwsStationArr.count) personal wx stations\n"
            var furthestPwsLat = 0.0
            var furthestPwsLon = 0.0

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
                let latDif = abs(lat - gSearchLat)
                let lonDif = abs(lon - gSearchLon)
                furthestPwsLat = max(latDif, furthestPwsLat)
                furthestPwsLon = max(lonDif, furthestPwsLon)

                let tupleDistDir = formatDistDir(latFrom: latVal, lonFrom: lonVal, latTo: lat, lonTo: lon, doMi: true, doDeg: false)
                let strDistDir = tupleDistDir.strDistDir
                //  var distStr = "     "
                //  let distNM = greatCircDist(ALat: latVal, ALon: lonVal, BLat: lat, BLon: lon)
                //  let distMi = distNM * 1.15
                //  let dirDeg = greatCircAng(ALat: latVal, ALon: lonVal, BLat: lat, BLon: lon, Dist: distNM)
                //  if distMi < 99 { distStr = distMi.format("5.1") }
                //  let distDirStr = "\(distStr)mi \(dirDeg)°"

                let strLatLon3 = formatLatLon(lat: lat, lon: lon, places: 3)

                //let km = dictStation["distance_km"] as? Double ?? -99
                print("🙂 \(self.codeFile)#\(#line) ")
                print (" ", padID, strLatLon3, state, city, neighborhood)
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
            print("Furthest pws: \(furthestPwsLat),\(furthestPwsLon)")

            self.tableView.reloadData()

        // Success again! We have made it through everything.
            self.lblError.text = ""
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activityIndicator.stopAnimating()

            self.txtCity.text = self.cityState
            self.enableButton(btn: self.btnCity, enable: isCityStateValid(self.cityState))

            self.txtZip.text = self.zip
            self.enableButton(btn: self.btnZip, enable: isZipValid(self.zip))
            self.txtLat.text = self.latStr
            self.txtLon.text = self.lonStr
            self.enableButton(btn: self.btnLatLon, enable: isLatValid(self.latStr) && isLonValid(self.lonStr) )
            self.lblDetail.text = self.detail

        }//end DispatchQueue
    }//end func

}//end extension: WuAPIdelegate


//MARK:- MapVCdelegate Extension
extension GeoLookupVC: MapVCdelegate {

    //delegate  - MapDelegate required method
    func mapVCreturn(_ controller: MapVC, returnType: LocationSelectionType, stationID: String, lat: Double, lon: Double) {   //delegate
        switch returnType {
        case .latlon:
            print("😃😃😃😃 \(codeFile)#\(#line) Update Map to \(lat), \(lon)😃😃😃😃")
            searchType = returnType
            let latText = lat.format(fmt: ".3")
            txtLat.text = latText
            let lonText = lon.format(fmt: ".3")
            txtLon.text = lonText
            lastSearch = latText + "," + lonText
            enableButton(btn: btnLatLon, enable: true)
        case .station:
            print("😃😃 \(codeFile)#\(#line) Update Map to \(stationID)😃😃")
            searchType = returnType
            txtStation.text = stationID
            lastSearch = stationID
            enableButton(btn: btnStation, enable: true)
        default: break
        }//end switch
    }//end func

}//end extension: MapVCdelegate


//MARK:- CLLocationManagerDelegate
extension GeoLookupVC: CLLocationManagerDelegate {

    //---- didUpdateLocations - when you get location from CLLocationManager, record gUserLat/gUserLon, & stop updates.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        gUserLat = userLocation.coordinate.latitude
        gUserLon = userLocation.coordinate.longitude
        print("\n🙂 \(codeFile)#\(#line) ** locationManager",gUserLat,gUserLon,"**\n")
        locationManager.stopUpdatingLocation()
    }

}//end extension: CLLocationManagerDelegate



//MARK:- UITextFieldDelegate ext
extension GeoLookupVC: UITextFieldDelegate {

    // ------ Dismiss Keybooard if user taps "Return" ------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 101 {
            print("🙂 \(codeFile)#\(#line) textField tag = \(textField.tag)")
            lookupStation()
        }
        return true
    }

}//end extension: UITextFieldDelegate
