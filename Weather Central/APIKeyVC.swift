//
//  APIKeyVC.swift
//  Weather Central
//
//  Created by George Bauer on 10/13/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import UIKit

class APIKeyVC: UIViewController, UITextFieldDelegate {

    var APItxt = ""
    var myError = ""

    @IBOutlet weak var txtAPIKey: UITextField!
    @IBOutlet weak var btnUpdateAPIKey: UIButton!
    @IBOutlet weak var lblAPIKey: UILabel!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //@IBOutlet weak var lblVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if gAPIKey != "" {
            lblAPIKey.text = gAPIKey
            txtAPIKey.text = gAPIKey
        } else {
            lblAPIKey.text = "Enter your wunderground.com API Key"
            txtAPIKey.text = ""
        }
        btnUpdateAPIKey.isEnabled = false

        //lblVersion.text = "Version \(gAppVersion)  Build \(gAppBuild)"
    }

    // ------ Dismiss Keybooard if user taps empty area ------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)  // used when FirstResponder is not known
    }
    
    // ------ Dismiss Keybooard if user taps "Return" ------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()    // a bit more efficient than endEditing, as textField is known
        return true
    }
    
    @IBAction func btnTestDate(_ sender: UIButton) {
    }
    
    //----------- API Key - Editing Change ---------
    @IBAction func txtAPIKeyEdit(_ sender: Any) {

        btnUpdateAPIKey.isEnabled = (txtAPIKey.text != lblAPIKey.text) && (txtAPIKey.text!.count >= 15)
    }//end @IBAction func txtMyAPIKeyEdit
    
    //------------------- Update APIKey Button ----------------
    @IBAction func btnUpdateAPIKeyTap(_ sender: UIButton) {
        self.view.endEditing(true)
        btnUpdateAPIKey.isEnabled = false
        APItxt = txtAPIKey.text!
        //lblError.text = ""
        let len = APItxt.count
        if len < 15 {
            showError("\(APItxt) is not a valid API key!!")
        } else {
            if APItxt.lowercased() != APItxt {
                showError("No upper-case characters allowed")
            } else {
            } //end if APItxt
        } //end if len

        let urlTuple = makeWuUrlJson(APIKey: APItxt, features: "conditions", place: "zip:34786")
        lblError.text = urlTuple.errorStr
        if urlTuple.errorStr == "" {
            let errorDownload = tryAPIKeyJSON(url: urlTuple.url)
            lblError.text = errorDownload
        }

    }//end @IBAction func btnAPIKey


    //MARK: - tryAPIKeyJSON JSON geolookup from wunderground.com
    //to make StandAlone - must return myError, globalDictJSON, working? (errShort, errLong)
    //---------------------- weatherJSON func ---------------------
    func tryAPIKeyJSON(url: URL) -> String {
        let checkLog = tryToLogCall(makeCall: true)
        if !checkLog.isOK { return "too many calls." }
        //------------------------------- task (thread) ------------------------------
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let response = response {
                print ("\n$$$$$$ response $$$$$$\n\(response)\n$$$$$$ end response $$$$$$\n")
            }
            guard error == nil, let dataReturned = data else {
                DispatchQueue.main.async {
                    print("\nweatherJSON Err202: ",error as AnyObject)
                    self.lblError.text = "Err202:\(error!)"
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false  // turn-off built-in activityIndicator
                    self.activityIndicator.stopAnimating()                          // turn-off My activityIndicator
                    //UIApplication.shared.endIgnoringInteractionEvents()           // if you were ignoring events

                    //self.lblDetail.text = error.debugDescription
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

            self.myError = ""

            jsonTry: do {
                let jsonResult = try JSONSerialization.jsonObject(with: dataReturned, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                guard let dictJson = jsonResult as? [String: AnyObject] else {  //Try to convert jsonResult to Dictionary
                    self.myError  = "Err203:Could not convert JSON to Dictionary"
                    print("\n\(self.myError)")
                    break jsonTry
                }
                //globalDictJSON = dictJson
                printDictionary(dict: dictJson, expandLevels: 0, dashLen: 0, title: "JSON")
                //self.printDictionary(dict: dictJson, expandLevels: 1, dashLen: 0, title: "JSON")

                guard let dictResponse =   dictJson["response"] as? [String: AnyObject] else { //Try to convert jsonResult["response"] to Dictionary
                    self.myError = "Err204:No 'response' in JSON data"
                    print("\n\(self.myError)")
                    break jsonTry
                }

                printDictionary(dict: dictResponse, expandLevels: 0, dashLen: 0, title: "Response")

                guard let dictFeatures = dictResponse["features"] as? [String: AnyObject] else { //Try to convert jsonResult.response.features to Dictionary
                    self.myError = "Err205:No 'features' in JSON 'response' data"
                    print("\n\(self.myError)")
                    break jsonTry}

                errorTry: do {      //See if there is an "error" entry in jsonResult.response
                    guard let dictError = dictResponse["error"] as? [String: AnyObject] else {self.myError = "";  break errorTry}
                    printDictionary(dict: dictError, expandLevels: 1, dashLen: 0, title: "response.error")
                    self.myError = "Err210:unknown error"
                    if let errType = dictError["type"]        as? String { self.myError = errType }
                    if let errDesc = dictError["description"] as? String { self.myError = errDesc }
                    print("\n\("Err210:" + self.myError)")
                    break jsonTry
                }// end errorTry

                resultsTry: do {    //See if there is a "results" entry in jsonResult.response (suggests other wx stations)
                    guard let oResults = dictResponse["results"] else {self.myError = "";  break resultsTry}
                    self.myError = "Place not found."
                    print("\n\(self.myError)")
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

            } catch { //jsonTry:do Try/Catch -  (try JSONSerialization.jsonObject) = failed
                self.myError = "Err208: Can't get JSON data!"
                print("\n\(self.myError)")
            }//end jsonTry:do Try/Catch

            // Success again! We have made it through everything.
            DispatchQueue.main.async {
                //————— Permanent Storage —————-
                if self.myError == "" {
                    gAPIKey = self.APItxt
                    UserDefaults.standard.set(gAPIKey, forKey: UDKey.wuAPIKey)//wuapikey")
                    self.showAlert(title: "Success", message: "APIKey updated to \(self.APItxt)")
                } else {
                    self.showAlert(title: "Fail", message: "Tryed API Key: \(self.APItxt)\n\(self.myError)")
                }

                self.lblError.text = self.myError
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityIndicator.stopAnimating()
            }// DispatchQueue.main.async

        } //----------------------------- end task (thread) -----------------------------------

        self.activityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        task.resume()
        return ""
    }//end func weatherJSON
    //MARK: end of weatherJSON -

    func showError(_ message: String) {
        showAlert(title: "Error", message: message)
    }
    
    func showAlert(title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
