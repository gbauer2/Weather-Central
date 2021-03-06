//
//  APIKeyVC.swift
//  Weather Central
//
//  Created by George Bauer on 10/13/17.
//  Copyright © 2017-2020 GeorgeBauer. All rights reserved.
//

import UIKit

class APIKeyVC: UIViewController, UITextFieldDelegate {

    var textAPI = ""
    var wuDownloadDone = false

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
    
    //----------- API Key - Editing Change ---------
    @IBAction func txtAPIKeyEdit(_ sender: Any) {
        let textAPI = txtAPIKey.text ?? ""
        btnUpdateAPIKey.isEnabled = (textAPI != lblAPIKey.text) && (textAPI.count >= 15)
        //btnUpdateAPIKey.isEnabled = true    //???-temp
    }//end @IBAction func txtMyAPIKeyEdit
    
    //------------------- Update APIKey Button ----------------
    @IBAction func btnUpdateAPIKeyTap(_ sender: UIButton) {
        self.view.endEditing(true)
        btnUpdateAPIKey.isEnabled = false
        textAPI = txtAPIKey.text ?? ""
        //lblError.text = ""
        let len = textAPI.count
        if len < 15 {
            showError("\(textAPI) is not a valid API key!!")
        } else {
            if textAPI.lowercased() != textAPI {
                showError("No upper-case characters allowed")
            } else {
            } //end if textAPI
        } //end if len

        let place = "zip:34786"
        let urlTuple = makeWuUrlJson(wuAPIKey: textAPI, features: "conditions", place: place)
        lblError.text = urlTuple.errorStr
        if urlTuple.errorStr == "" {
            let wuURL = urlTuple.url
            startWuDownload(wuURL: wuURL, place: place)
        }

    }//end @IBAction func btnAPIKey

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

//MARK: =================== WuAPIdelegate Extension =======================
extension APIKeyVC: WuAPIdelegate {
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

    func wuAPIdownloadDone(_ controller: WuAPI, isOK: Bool, numFeaturesRequested: Int,  numFeaturesReceived: Int, errStr: String){    //delegate (6)
        DispatchQueue.main.async {
            print("APIKeyVC downloadDone delegate reached:")
            print("errStr = \(errStr)")
            let es = isOK ? "" : "\(errStr)\n"
            let msg = "isOK = \(isOK)\n\(es)\(numFeaturesRequested) features requested, \(numFeaturesReceived) received."
            print(msg)

            //----------------------------
            //process your data
            UIApplication.shared.isNetworkActivityIndicatorVisible = false  // turn-off built-in activityIndicator
            self.activityIndicator.stopAnimating()                          // turn-off My activityIndicator

            if isOK {
                gAPIKey = self.textAPI
                UserDefaults.standard.set(gAPIKey, forKey: UDKey.wuAPIKey)//wuapikey")
                self.showAlert(title: "Success", message: "APIKey updated to \(self.textAPI)")
            } else {
                self.lblError.text = msg
                self.showAlert(title: "Fail", message: "Tried API Key: \(self.textAPI)\n\(errStr)")
            }//end if else
        }//end DispatchQueue
    }//end func
}//end extension

