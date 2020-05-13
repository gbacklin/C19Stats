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
    var sumLatestTotal = -1

    var regionData: [String: [JHUModel]]? {
        get {
            return appDelegate.regionData
        }
        set {
            appDelegate.regionData?.removeAll()
            appDelegate.regionData = newValue
        }
    }

    var isNewDataSample: Bool {
        get {
            return appDelegate.isNewDataSample
        }
        set {
            appDelegate.isNewDataSample = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        self.navigationItem.title = "C19 Regions"
        if isNewDataSample {
            tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
            isNewDataSample = false
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        self.navigationItem.title = ""
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sumLatestTotal = -1
        return 1
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
        
        if sumLatestTotal == -1 {
            sumLatestTotal = getSumLatestTotal(regionArray!)
        }
        cell.textLabel?.text = regionKey
        cell.detailTextLabel?.text = "\(sumLatestTotal) in \(regionArray!.count) regions"
        sumLatestTotal = -1
        
        return cell
    }

    func getSumLatestTotal(_ array: [JHUModel]) -> Int {
        var subTotal = 0
        for rec in array {
            subTotal += Int(rec.latestTotal)!
        }
        return subTotal
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
