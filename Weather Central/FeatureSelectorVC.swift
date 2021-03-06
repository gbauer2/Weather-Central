//
//  FeatureSelectorVC.swift
//  Weather Central
//
//  Created by George Bauer on 8/30/17.
//  Copyright © 2017-2020 GeorgeBauer. All rights reserved.
//

import UIKit

class FeatureSelectorVC: UIViewController, UITextFieldDelegate {
    
    //MARK: ---- Variables ----
    let codeFile = "FeatureSelectorVC"
    let allowedFeatures = ["xxx", "alerts", "almanac", "astronomy", "conditions", "currenthurricane", "forecast", "forecast10day", "geolookup", "history", "hourly", "hourly10day", "planner--------", "rawtide", "satellite", "tide", "webcams", "yesterday"]

    var plannerSuffix = "09010910"

    var featuresStr = ""
    var didAddFeature = false

    //MARK: ---- @IBOutlets ----
    @IBOutlet weak var btnCheck:  UIButton!
    @IBOutlet weak var lblError:  UILabel!
    @IBOutlet weak var btnSave: UIBarButtonItem!

    @IBOutlet weak var txtDate1: UITextField!
    @IBOutlet weak var txtDate2: UITextField!

    //MARK: ---- Overrides ----
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Load wuFeaturesArr[] from permanent storage "wuFeaturesArray"
        let nameObject = UserDefaults.standard.object(forKey: UDKey.featuresArr)//"wuFeaturesArray")
        if let temp = nameObject as? [Bool] {
            print("🙂 \(codeFile)#\(#line) wuFeaturesArray = \(temp)")
            wuFeaturesArr = temp
        } else {
            print("😡 \(codeFile)#\(#line) UserDefaults.standard.object(forKey: \"\(UDKey.featuresArr)\") NOT Found.")
        } //end if let name
        
        // 2. Set Selection Status on Check Buttons according to wuFeaturesArr[]
        for i in 1..<18 {
            if let button = view.viewWithTag(i) as? UIButton {
                //button.setImage(UIImage(named: "checkbox_no"), for: [])
                button.isSelected = wuFeaturesArr[button.tag]
            }//endif let
        }//next i
        
        // 3. Load planner date1 from permanent storage "wuPlannerDate1"
        txtDate1.text = UserDefaults.standard.object(forKey: UDKey.wuPlannerDate1) as? String ?? ""

        // 4. Load planner date2 from permanent storage "wuPlannerDate2"
        txtDate2.text = UserDefaults.standard.object(forKey: UDKey.wuPlannerDate2) as? String ?? ""

        didAddFeature = false
        btnSave.isEnabled = false
        txtDate1.isEnabled = wuFeaturesArr[iPlanner]
        txtDate2.isEnabled = wuFeaturesArr[iPlanner]
        txtDate1.isHidden = !wuFeaturesArr[iPlanner]
        txtDate2.isHidden = !wuFeaturesArr[iPlanner]
    }
    
    // ------ Dismiss Keybooard if user taps empty area ------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // ------ Dismiss Keybooard if user taps "Return" ------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //-------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    //MARK: ---- @IBActions ----
    @IBAction func btnClearPress(_ sender: Any) {
        for i in 0..<18 {
            if let button = view.viewWithTag(i) as? UIButton {
                wuFeaturesArr[i] = false
                button.isSelected = false
            }//endif let
        }//next i
    }//end func
    
    //---- Save Button Tapped ----
    @IBAction func btnSaveTap(_ sender: UIButton) {
        // Save wuFeaturesArr[] in permanent storage "wuFeaturesArray"
        self.view.endEditing(true)
        UserDefaults.standard.set(wuFeaturesArr, forKey: UDKey.featuresArr)//"wuFeaturesArray")
        
        // Create featuresStr string from wuFeaturesArr[]
        if wuFeaturesArr[iPlanner] {
            plannerSuffix = makePlannerSuffix()
            if plannerSuffix.count != 9 || !plannerSuffix.hasPrefix("_") {
                lblError.text = "\(plannerSuffix)"
                return
            }
            UserDefaults.standard.set(txtDate1.text ?? "??", forKey: UDKey.wuPlannerDate1)//"wuPlannerDate1")
            UserDefaults.standard.set(txtDate2.text ?? "??", forKey: UDKey.wuPlannerDate2)//"wuPlannerDate2")
        }//endif wuFeaturesArr[idxPlanner]
        
        if didAddFeature { gDataIsCurrent = false }
        
        featuresStr = ""
        for i in 1..<18 {
            if wuFeaturesArr[i] {
                featuresStr += allowedFeatures[i] + "/"
            }//endif
        }//next i
        featuresStr = featuresStr.replacingOccurrences(of: "--------", with: plannerSuffix)
        
        // Save featuresStr string in permanent storage "wuFeatures"
        UserDefaults.standard.set(featuresStr, forKey: UDKey.featuresStr)//"wuFeatures")
        
        print("🙂 \(codeFile)#\(#line) featuresStr = \n    \(featuresStr)")
        //navigationController?.popViewController(animated: true)
        guard (navigationController?.popToRootViewController(animated:true)) != nil else {
            print("😡 \(codeFile)#\(#line) No navigationController")
            return
        }
    }//end func
    
    //------ One of the Checkboxes was Pressed ------
    @IBAction func btnCheckPress(_ sender: UIButton) {
        self.view.endEditing(true)
        
        //let sendr = sender as! UIButton
        
        sender.isSelected = !sender.isSelected
        //sendr.setImage(UIImage(named: "checkbox_no"), for: UIControlState.normal)
        if sender.isSelected {
            didAddFeature = true                    // a Feature has been added
        }
        btnSave.isEnabled = true

        wuFeaturesArr[sender.tag] = sender.isSelected
        
        toggleItems(newItem: sender.tag)
        
        print("🙂 \(codeFile)#\(#line)\n", wuFeaturesArr)
    }
 
    @IBAction func txtDate1Edit(_ sender: UITextField) {
        editMonthDay(sender: sender, is1or2: 1)
    }
    @IBAction func txtDate2Edit(_ sender: UITextField) {
        editMonthDay(sender: sender, is1or2: 2)
    }

    func editMonthDay(sender: UITextField, is1or2: Int) {
        didAddFeature = true
        btnSave.isEnabled = didAddFeature

        let textAfter = sender.text ?? ""
        print("🙂 \(codeFile)#\(#line) \(textAfter)")

        switch textAfter.count {
        case 0:
            return                              // empty - ok
        case 1:
            if isNumeric(textAfter) { return }  // single digit - ok
        case 2:
            if isNumeric(textAfter) {
                let mo = Int(textAfter) ?? 0
                if mo >= 1 && mo <= 12 {
                    return                      // 2 digits - ok
                }
            } else if textAfter.right(1) == "/" && textAfter.left(1) != "0" {
                sender.text = "0" + textAfter.left(1) + "/"
                return                          // "3/" --> "03/"
            }
        case 3:
            if isNumeric(textAfter) {
                let mo = Int(textAfter.left(2)) ?? 0
                if mo >= 1 && mo <= 12 {
                    sender.text = textAfter.left(2) + "/" + textAfter.right(1)
                }
                return                      // "12/6"
            } else {
                sender.text = textAfter.left(2) + "/"
                return
            }
        case 4:
            if isNumeric(textAfter.right(1)){
                return
            }
        case 5:
            if isNumeric(textAfter.right(2)){
                let day = Int(textAfter.right(2)) ?? 0
                if day >= 1 && day <= 31 {
                    return
                }
            }
        default: break
        }//end switch
        sender.text = textAfter.left(textAfter.count - 1) // remove the last char
    }//end func

    //MARK: ---- support funcs ----
    func makePlannerSuffix() -> String {
        let mmdd1 = makeMMDD(mm_dd: txtDate1.text ?? "")
        if mmdd1.count != 4 {return "1st " + mmdd1}

        let mmdd2 = makeMMDD(mm_dd: txtDate2.text ?? "")
        if mmdd2.count != 4 {return "2nd " + mmdd2}

        var int1 = Int(mmdd1) ?? 0
        let int2 = Int(mmdd2) ?? 0
        if int1 > 1200 { int1 = int1 - 1200}
        if int1 > int2 {
            return "2nd planner date must be >= 1st"
        }
        return "_" + mmdd1 + mmdd2
    }

    // return "MMDD" from "MM/DD" or "MM/D" or return error message
    func makeMMDD(mm_dd: String) -> String {
        var mmdd = mm_dd
        var errMsg = "planner date must be of form \"mm/dd\""
        mmdd = mmdd.trimmingCharacters(in: .whitespacesAndNewlines)
        if (mmdd.count != 5 && mmdd.count != 4) || mmdd.substring(begin: 2, length: 1) != "/"  { return errMsg }
        let splitTxt = mmdd.components(separatedBy: "/")
        if splitTxt.count != 2        { return errMsg }
        
        let moStr = splitTxt[0]
        var daStr = splitTxt[1]
        errMsg = "planner month can't be \(moStr)"
        guard let mon = Int(moStr) else { return errMsg }
        if mon < 1 || mon > 12            { return errMsg }

        errMsg = "planner day can't be \(daStr)"
        guard let day = Int(daStr) else                         { return errMsg }
        if day < 1 || day > 31                                  { return errMsg }
        if day <= 9 && !daStr.hasPrefix("0") { daStr = "0" + daStr }
        if (mon == 4 || mon == 6 || mon == 9 || mon == 11) && day > 30 { return errMsg }
        if (mon == 2) && day > 29                               { return errMsg }
        return moStr + daStr
    }
    
    
    //-------------------------------------
    //for those Features that are mutually exclusive: uncheck the other
    func toggleItems(newItem: Int) {

        txtDate1.isEnabled = wuFeaturesArr[iPlanner]
        txtDate2.isEnabled = wuFeaturesArr[iPlanner]
        txtDate1.isHidden = !wuFeaturesArr[iPlanner]
        txtDate2.isHidden = !wuFeaturesArr[iPlanner]

        wuFeaturesArr[iAstronomy] = wuFeaturesArr[iAlmanac]
        if wuFeaturesArr[newItem] == false {
            return
        }
        // 6, 7 forecast/10day
        // 9,17 history/yesterday
        //10,11 hourly/10day
        //12    planner
        var oldItem1 = 0
        var oldItem2 = 0
        
        switch newItem {
        case iForecast:
            oldItem1 = iForecast10day
        case iForecast10day:
            oldItem1 = iForecast
        case iHistory:
            oldItem1 = iYesterday
            oldItem2 = iPlanner
        case iYesterday:
            oldItem1 = iHistory
            oldItem2 = iPlanner
        case iPlanner:
            oldItem1 = iHistory
            oldItem2 = iYesterday
        case iHourly:
            oldItem1 = iHourly10Day
        case iHourly10Day:
            oldItem1 = iHourly
        default:
            oldItem1 = 0
        }//end switch
     
        if oldItem1 == 0 && oldItem2 == 0 {
            return
        }



        if oldItem1 != 0 {
            wuFeaturesArr[oldItem1] = false
            if let button = view.viewWithTag(oldItem1) as? UIButton {
                button.isSelected = false
            }//endif let
        }//endif oldItem1
        
        if oldItem2 != 0 {
            wuFeaturesArr[oldItem2] = false
            if let button = view.viewWithTag(oldItem2) as? UIButton {
                button.isSelected = false
            }//endif let
        }//endif oldItem2

        txtDate1.isEnabled = wuFeaturesArr[iPlanner]
        txtDate2.isEnabled = wuFeaturesArr[iPlanner]
        txtDate1.isHidden = !wuFeaturesArr[iPlanner]
        txtDate2.isHidden = !wuFeaturesArr[iPlanner]

    }//end func toggleItems
    
    //=====================================================================
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

     * alerts           alerts -----> ...
     * almanac          almanac ----> ...
     * astronomy        sun_phase --> ..., moon_phase --> ...
     * conditions       current_observation --> ...
     * currenthurricane currenthurricane -----> ...
     * forecast         forecast ---> ...
     * forecast10day    forecast ---> ...
     * geolookup        location ---> ...
     * history          history ----> ...
     * hourly           hourly_forecast --> ...
     * hourly10day      hourly_forecast --> ...
     * planner          trip -------> ...
     * rawtide          rawtide ----> ...
     * satellite        satellite --> ...
     * tide             tide -------> ...
     * webcams          webcams ----> ...
     * yesterday        history ----> ...
     */

}
