//
//  SettingsTVC.swift
//  Weather Central
//
//  Created by George Bauer on 11/16/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController {

    @IBOutlet var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            return "Weather Central \(gAppVersion)"
//        case 1:
//            return "Testing"
//        default:
//            return "?????"
//        }
//    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //print(tableView.bounds.size.width, tableView.bounds.size.height)
        if section == 0 {
            let headerView = UIView()
            let headerLabel = UILabel(frame: CGRect(x: 0, y: 4, width: tableView.bounds.size.width, height: 28))

            headerView.backgroundColor = UIColor.lightGray
            headerLabel.font = UIFont(name: "Verdana", size: 22)
            headerLabel.textColor = UIColor.white
            //headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section) // default text
            headerLabel.text = "Weather Central \(gAppVersion)"
            //headerLabel.sizeToFit()

            headerLabel.textAlignment = .center         // does not work if orientation changes while on screen without ## constraints
            headerView.addSubview(headerLabel)

            headerLabel.translatesAutoresizingMaskIntoConstraints = false                   //## to force recentering on orientation change
            headerLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true       //##
            headerLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true     //##
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true //## keeps label centered vertically
            //headerLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true                //## not needed

            return headerView
        } else {
            return nil          // default header
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 40
        default:
            return 22
        }
    }//end func

}
