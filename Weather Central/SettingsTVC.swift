//
//  SettingsTVC.swift
//  Weather Central
//
//  Created by George Bauer on 11/16/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import UIKit

struct Cel {
    let title : String
    let detail : String
    let image : UIImage?
}

class SettingsTVC: UITableViewController {



    @IBOutlet var table: UITableView!

    //let sectionNames = ["General","Testing"]

    //let generalCell = [Cel(title: "About", detail: "", image: nil),
    //               Cel(title: "Change API Key", detail: "", image: nil),
    //                ]
    //let testCell = [Cel(title: "Test Call Limits", detail: "", image: nil),
    //                   ]


    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionNames[section]
//    }

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 2
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        switch section {
//        case 0:
//            return generalCell.count
//        case 1:
//            return testCell.count
//        default:
//            return 1
//        }
//    }


//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//
//        // Configure the cell...
//        switch indexPath.section {
//        case 0:
//            cell.textLabel?.text = generalCell[indexPath.row].title
//            cell.detailTextLabel?.text = generalCell[indexPath.row].detail
//        case 1:
//            cell.textLabel?.text = testCell[indexPath.row].title
//            cell.detailTextLabel?.text = testCell[indexPath.row].detail
//        default:
//            cell.textLabel?.text = "Section \(indexPath.section) not set up!"
//        }
//        return cell
//    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
