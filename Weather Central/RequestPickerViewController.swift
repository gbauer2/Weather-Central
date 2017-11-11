//
//  RequestPickerViewController.swift
//  Downloading Web Content
//
//  Created by George Bauer on 8/29/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import UIKit

class RequestPickerViewController: UIViewController {
    
        
   /*
        if (sender.isSelected == true)
        {
            sender.setBackgroundImage(UIImage(named: "checkbox_no"), for: UIControlState.normal)
            sender.isSelected = false;
        }
        else
        {
            sender.setBackgroundImage(UIImage(named: "checkbox_yes"), for: UIControlState.normal)
            sender.isSelected = true;
        }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


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
}

