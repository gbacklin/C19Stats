//
//  ViewController.swift
//  C19Stats
//
//  Created by Gene Backlin on 5/6/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    var selectedDataType: DataType?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.messageLabel.text = ""
    }

    @IBAction func selectReportType(_ sender: Any) {
        self.messageLabel.text = ""
        presentActionSheet(sender)
    }
    
    func presentActionSheet(_ sender: Any) {
        let controller = UIAlertController(title: "Category", message: "Select data sample", preferredStyle: .actionSheet)
        let usConfirmedAction = UIAlertAction(title: "US Confirmed", style: .default) {[unowned self] (action) in
            self.activityIndicator.startAnimating()
            self.writeFile(dataType: .confirmus)
        }
        let usDeathAction = UIAlertAction(title: "US Deaths", style: .default) {[unowned self] (action) in
            self.activityIndicator.startAnimating()
            self.writeFile(dataType: .deathus)
        }
        let globalConfirmedAction = UIAlertAction(title: "Global Confirmed", style: .default) {[unowned self] (action) in
            self.activityIndicator.startAnimating()
            self.writeFile(dataType: .confirmglobal)
        }
        let globalDeathAction = UIAlertAction(title: "Global Deaths", style: .default) {[unowned self] (action) in
            self.activityIndicator.startAnimating()
            self.writeFile(dataType: .deathglobal)
        }
        let globalRecoveredAction = UIAlertAction(title: "Global Recovered", style: .default) {[unowned self] (action) in
            self.activityIndicator.startAnimating()
            self.writeFile(dataType: .recoveredglobal)
        }
        controller.addAction(usConfirmedAction)
        controller.addAction(usDeathAction)
        controller.addAction(globalConfirmedAction)
        controller.addAction(globalDeathAction)
        controller.addAction(globalRecoveredAction)
        
        if let popoverController = controller.popoverPresentationController {
          popoverController.sourceView = self.view
          popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
          popoverController.permittedArrowDirections = []
        }

        present(controller, animated: true, completion: nil)
    }

    func writeFile(dataType: DataType) {
        selectedDataType = dataType
        messageLabel.text = "Fetching results..."
        JHUData.shared.fetch(type: dataType) {[unowned self] (results, csv, error) in
            var filename: String = ""
            self.activityIndicator.stopAnimating()
            
            switch dataType {
            case .confirmus:
                filename = "C19ConfirmStatsUS.csv"
            case .deathus:
                filename = "C19DeathStatsUS.csv"
            case .confirmglobal:
                filename = "C19ConfirmStatsGlobal.csv"
            case .deathglobal:
                filename = "C19DeathStatusGlobal.csv"
            case .recoveredglobal:
                filename = "C19RecoveredStatsGlobal.csv"
            }
            let documents: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            let writePath = documents.appendingPathComponent(filename)
            if let confirm = results?["confirm"] {
                self.messageLabel.text = "There were \(confirm.count) records retrieved. The file \(filename) is in the Documents folder"
                //(confirm as NSArray).write(toFile: writePath, atomically: true)
                self.saveFile(path: writePath, data: csv!)
            }
            if let death = results?["death"] {
                self.messageLabel.text = "There were \(death.count) records retrieved. The file \(filename) is is in the Documents folder"
                //(death as NSArray).write(toFile: writePath, atomically: true)
                self.saveFile(path: writePath, data: csv!)
            }
            if let recovered = results?["recovered"] {
                self.messageLabel.text = "There were \(recovered.count) records retrieved. The file \(filename) is is in the Documents folder"
                //(recovered as NSArray).write(toFile: writePath, atomically: true)
                self.saveFile(path: writePath, data: csv!)
            }
        }
    }
    
    func saveFile(path: String, data: String) {
        if let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            debugPrint(doc)
            //writing
            do {
                try data.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func readFile(path: String) -> String? {
        var data: String?
        if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil {
            //reading
            do {
                data = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        return data
    }

}

