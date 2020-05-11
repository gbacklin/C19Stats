//
//  RegionTableViewController.swift
//  C19Stats
//
//  Created by Gene Backlin on 5/10/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

import UIKit

class RegionTableViewController: UITableViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var regionData: [String: [JHUModel]]? {
        get {
            return appDelegate.regionData
        }
        set {
            appDelegate.regionData = newValue
        }
    }

    var indexArray: [String]?
    var namesDictionary: [String : [JHUModel]]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        self.navigationItem.title = "C19 Regions"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        self.navigationItem.title = ""
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        if let data = regionData {
            count = Array(data.keys).count
        }
        return count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if let data = regionData {
            count = data.count
        }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let keys = Array(regionData!.keys).sorted()
        let key = keys[indexPath.row]
        let regionKey = key
        let regionArray = regionData![key]
        
        cell.textLabel?.text = regionKey
        cell.detailTextLabel?.text = "\(regionArray!.count) regions"

        return cell
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRegionInfo" {
            
            let controller: ModelDetailViewController = segue.destination as! ModelDetailViewController
            let indexPath = tableView.indexPathForSelectedRow
            let keys = Array(regionData!.keys).sorted()
            let key = keys[indexPath!.row]
            let regionArray = regionData![key]
            controller.model = nil
            controller.regions = regionArray
        }
    }

}
