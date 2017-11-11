//
//  TestDateViewController.swift
//  Weather Central
//
//  Created by George Bauer on 10/13/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import UIKit

class TestDateViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    //self.settingsBarButton.title = NSString(string: "\u{2699}"), if let font = UIFont(name: "Helvetica", size: 18.0) ... self.settingsBarButton.setTitleTextAttributes([NSFontAttribu‌​teName: font], forState: UIControlState.Normal)
        //self.lblResults.text = "\u{2699}⚙️"
        if let font = UIFont(name: "Helvetica", size: 18.0) {
            self.lblResults.font = font //([NSFontAttribu‌​teName: font], forState: UIControlState.Normal)
        }
        let tryCall = tryToLogCall(makeCall: false)
        showCallLog(isOK: tryCall.isOK, numCallsLastMinute: tryCall.numCallsLastMinute, msg: tryCall.msg)
    }

    
    @IBOutlet weak var lblResults: UILabel!
    
    @IBAction func btnTestTap(_ sender: UIButton) {

        let tryCall = tryToLogCall(makeCall: true)
        showCallLog(isOK: tryCall.isOK, numCallsLastMinute: tryCall.numCallsLastMinute, msg: tryCall.msg)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func showCallLog(isOK: Bool, numCallsLastMinute: Int, msg: String) {
        //: Start with initializing a date formatter
        let dateFormatter = DateFormatter()
        //You have a choice of .full .long, .medium, .short, and .none
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        //: There's a function on date formatters, that return a string with the formatted date.
        //print(dateFormatter.string(from: date))
        var aa = ""
        aa  += "isOK = \(isOK)\n"
        if !isOK {
            aa += "Try again \(msg).\n"
        }

        aa += "\n"
        aa += "numCallsLastMinute = \(numCallsLastMinute)\n"
        aa += "\n"
        aa += "numCallsToday = \(gNumCallsToday)\n"
        aa += "\n"

        aa += "dateStartup = "  + dateFormatter.string(from: gDateStartup) + "\n"
        aa += "dateLastRun = "  + dateFormatter.string(from: gDateLastRun) + "\n"
        aa += "dateLastCall = " + dateFormatter.string(from: gDateLastCall) + "\n"
        aa += "ymdLastCallET = \(gYmdLastCallET)\n"
        lblResults.text = aa
        
    }
}
