//
//  AboutVC.swift
//  Weather Central
//
//  Created by George Bauer on 11/16/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    @IBOutlet weak var lblVersion: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblVersion.text = "Version \(gAppVersion)  Build \(gAppBuild)"

    }


}
