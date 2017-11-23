//
//  APIKeyVC.swift
//  Weather Central
//
//  Created by George Bauer on 10/13/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtAPIKey: UITextField!
    @IBOutlet weak var btnUpdateAPIKey: UIButton!
    @IBOutlet weak var lblAPIKey: UILabel!

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
        btnUpdateAPIKey.isEnabled = txtAPIKey.text!.count >= 15
    }//end @IBAction func txtMyAPIKeyEdit
    
    //------------------- Update APIKey Button ----------------
    @IBAction func btnUpdateAPIKeyTap(_ sender: UIButton) {
        self.view.endEditing(true)
        btnUpdateAPIKey.isEnabled = false
        let APItxt = txtAPIKey.text!
        //lblError.text = ""
        let len = APItxt.count
        if len < 15 {
            showError("\(APItxt) is not a valid API key!!")
        } else {
            if APItxt.lowercased() != APItxt {
                showError("No upper-case characters allowed")
            } else {
                //————— Permanent Storage —————-
                gAPIKey = APItxt
                UserDefaults.standard.set(gAPIKey, forKey: UDKey.wuAPIKey.rawValue)//wuapikey")
                showAlert(title: "Success", message: "APIKey updated to \(APItxt)")
            } //end if APItxt
        } //end if len
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
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
