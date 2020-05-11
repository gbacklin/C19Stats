//
//  FirstViewController.swift
//  C19Stats
//
//  Created by Gene Backlin on 5/8/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

import UIKit

let CELL_HEIGHT: CGFloat = 50.0

class FirstViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var composeBarButtonItem: UIBarButtonItem!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var indexArray: [String]?
    var namesDictionary: [String : [JHUModel]]?


    var outputPath: String? {
        get {
            return appDelegate.outputPath
        }
        set {
            appDelegate.outputPath = newValue
        }
    }
    var outputFilename: String? {
        get {
            return appDelegate.outputFilename
        }
        set {
            appDelegate.outputFilename = newValue
        }
    }
    var outputCSVData: String? {
        get {
            return appDelegate.outputCSVData
        }
        set {
            appDelegate.outputCSVData = newValue
        }
    }
    var modelData: [JHUModel]? {
        get {
            return appDelegate.modelData
        }
        set {
            appDelegate.modelData?.removeAll()
            appDelegate.modelData = newValue
        }
    }
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
        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = CELL_HEIGHT
        messageLabel.text = "Select folder on upper right to fetch data."
        indexArray = initIndex()
        composeBarButtonItem.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "C19 Statistics"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
    }

    @IBAction func fetchData(_ sender: Any) {
        composeBarButtonItem.isEnabled = false
        messageLabel.text = ""
        namesDictionary?.removeAll()
        namesDictionary = nil
        isNewDataSample = true
        tableView.reloadData()
        presentActionSheet()
    }
    
    @IBAction func writeFileToDocuments(_ sender: Any) {
        messageLabel.text = "The file: \(outputFilename!) can be found in the Document folder."
        JHUData.shared.saveFile(path: outputPath!, data: outputCSVData!)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowModelData" {
            let controller: ModelDetailViewController = segue.destination as! ModelDetailViewController
            let indexPath = tableView.indexPathForSelectedRow
            let key = indexArray![indexPath!.section]
            let modelArray: [JHUModel] = namesDictionary![String(key)]!
            controller.model = modelArray[indexPath!.row]
        }
    }
    
    // MARK: - Utility
    
    func initIndex() -> [String] {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var index: [String] = [String]()
        
        for c in alphabet {
            index.append(String(c))
        }
        return index
    }

    func numberOfItemsForSection(section: Int) -> Int {
        var count = 0
        if namesDictionary != nil {
            let key = indexArray![section]
            if let names: [JHUModel] = namesDictionary![String(key)] {
                count = names.count
            }
        }
        return count
    }

    func initNamesDictionary(models: [JHUModel]) -> [String : [JHUModel]] {
        var names: [String : [JHUModel]] = [String : [JHUModel]]()
        
        for model in models {
            var name = ""
            if model.uid.count > 0 {
                name = model.provinceState
            } else {
                name = model.countryRegion
            }
            let c = (name as NSString).character(at: 0)
            let key = String(format: "%c", c)
            var list: [JHUModel]? = names[key]
            
            if list == nil {
                list = [JHUModel]()
            }
            list!.append(model)
            names[key] = list
        }
        return names
    }

}
extension FirstViewController {
    func presentActionSheet() {
        let controller = UIAlertController(title: "Category", message: "Select data sample", preferredStyle: .actionSheet)
        let usConfirmedAction = UIAlertAction(title: "US Confirmed", style: .default) {[unowned self] (action) in
            self.activityIndicator.startAnimating()
            self.messageLabel.text = "Fetching results..."
            JHUData.shared.saveResults(dataType: .confirmus) {[weak self] (path, filename, csv, models, regions, error, message) in
                DispatchQueue.main.async {
                    if self!.namesDictionary == nil {
                        self!.namesDictionary = self!.initNamesDictionary(models: models!)
                    }
                    self!.activityIndicator.stopAnimating()
                    self!.outputPath = path
                    self!.outputFilename = filename
                    self!.outputCSVData = csv
                    self!.modelData = models
                    self!.regionData = regions
                    self!.messageLabel.text = message
                    self!.composeBarButtonItem.isEnabled = true
                    self!.tableView.reloadData()
                }
            }
        }
        let usDeathAction = UIAlertAction(title: "US Deaths", style: .default) {[unowned self] (action) in
            self.activityIndicator.startAnimating()
            self.messageLabel.text = "Fetching results..."
            JHUData.shared.saveResults(dataType: .deathus) {[weak self] (path, filename, csv, models, regions, error, message) in
                DispatchQueue.main.async {
                    if self!.namesDictionary == nil {
                        self!.namesDictionary = self!.initNamesDictionary(models: models!)
                    }
                    self!.activityIndicator.stopAnimating()
                    self!.outputPath = path
                    self!.outputFilename = filename
                    self!.outputCSVData = csv
                    self!.modelData = models
                    self!.regionData = regions
                    self!.messageLabel.text = message
                    self!.composeBarButtonItem.isEnabled = true
                    self!.tableView.reloadData()
                }
            }
        }
        let globalConfirmedAction = UIAlertAction(title: "Global Confirmed", style: .default) {[unowned self] (action) in
            self.activityIndicator.startAnimating()
            self.messageLabel.text = "Fetching results..."
            JHUData.shared.saveResults(dataType: .confirmglobal) {[weak self] (path, filename, csv, models, regions, error, message) in
                DispatchQueue.main.async {
                    if self!.namesDictionary == nil {
                        self!.namesDictionary = self!.initNamesDictionary(models: models!)
                    }
                    self!.activityIndicator.stopAnimating()
                    self!.outputPath = path
                    self!.outputFilename = filename
                    self!.outputCSVData = csv
                    self!.modelData = models
                    self!.regionData = regions
                    self!.messageLabel.text = message
                    self!.composeBarButtonItem.isEnabled = true
                    self!.tableView.reloadData()
                }
            }
        }
        let globalDeathAction = UIAlertAction(title: "Global Deaths", style: .default) {[unowned self] (action) in
            self.activityIndicator.startAnimating()
            self.messageLabel.text = "Fetching results..."
            JHUData.shared.saveResults(dataType: .deathglobal) {[weak self] (path, filename, csv, models, regions, error, message) in
                DispatchQueue.main.async {
                    if self!.namesDictionary == nil {
                        self!.namesDictionary = self!.initNamesDictionary(models: models!)
                    }
                    self!.activityIndicator.stopAnimating()
                    self!.outputPath = path
                    self!.outputFilename = filename
                    self!.outputCSVData = csv
                    self!.modelData = models
                    self!.regionData = regions
                    self!.messageLabel.text = message
                    self!.composeBarButtonItem.isEnabled = true
                    self!.tableView.reloadData()
                }
            }
        }
        let globalRecoveredAction = UIAlertAction(title: "Global Recovered", style: .default) {[unowned self] (action) in
            self.activityIndicator.startAnimating()
            self.messageLabel.text = "Fetching results..."
            JHUData.shared.saveResults(dataType: .recoveredglobal) {[weak self] (path, filename, csv, models, regions, error, message) in
                DispatchQueue.main.async {
                    if self!.namesDictionary == nil {
                        self!.namesDictionary = self!.initNamesDictionary(models: models!)
                    }
                    self!.activityIndicator.stopAnimating()
                    self!.outputPath = path
                    self!.outputFilename = filename
                    self!.outputCSVData = csv
                    self!.modelData = models
                    self!.regionData = regions
                    self!.messageLabel.text = message
                    self!.composeBarButtonItem.isEnabled = true
                    self!.tableView.reloadData()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {[unowned self] (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        controller.addAction(usConfirmedAction)
        controller.addAction(usDeathAction)
        controller.addAction(globalConfirmedAction)
        controller.addAction(globalDeathAction)
        controller.addAction(globalRecoveredAction)
        controller.addAction(cancelAction)

        if let popoverController = controller.popoverPresentationController {
          popoverController.sourceView = self.view
          popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
          popoverController.permittedArrowDirections = []
        }

        present(controller, animated: true, completion: nil)
    }

}

// MARK: - UITableViewDataSource

extension FirstViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return indexArray!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if modelData != nil {
            count = numberOfItemsForSection(section: section)
        }
        return count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexArray
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerTitle = ""
        
        if numberOfItemsForSection(section: section) > 0 {
            headerTitle = String(indexArray![section])
        }
        return headerTitle
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let key = indexArray![indexPath.section]
        let modelArray: [JHUModel] = namesDictionary![String(key)]!

        let object = modelArray[indexPath.row]
        if object.uid.count > 0 {
            cell.textLabel?.text = "\(object.provinceState) \(object.county)"
        } else {
            cell.textLabel?.text = "\(object.countryRegion)"
        }
        cell.detailTextLabel?.text = "\(object.latestTotal) reported"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
}
