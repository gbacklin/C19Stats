//
//  JHUData.swift
//  C19Stats
//
//  Created by Gene Backlin on 5/6/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

import UIKit

let JHU_URL = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/"

enum DataType {
    case confirmus
    case deathus
    case confirmglobal
    case deathglobal
    case recoveredglobal
}

class JHUData: NSObject {
    static var shared = JHUData()

    func fetchData(url: String, completion: @escaping (_ results: Any?,_ csv: String?, _ error: NSError?) -> Void) {
        // Fetch data...
        Network.shared.getCSV(url: url) { [weak self] (results, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
            } else {
                if let rawData: String = results as? String {
                    let parsedData = rawData.split(separator: "\n")
                    var dataArray: [String] = [String]()
                    for data in parsedData {
                        dataArray.append(String(data))
                    }
                    DispatchQueue.main.async {
                        completion(dataArray, rawData, nil)
                    }
                } else {
                    let error: NSError = self!.createError(domain: NSURLErrorDomain, code: -1955, text: "The results from the query were nil") as NSError
                    DispatchQueue.main.async {
                        completion(nil, nil, error)
                    }
                }
            }
        }
    }
    
    // MARK: - Utility methods
    
    func convertDate(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date: NSDate = dateFormatter.date(from: dateString)! as NSDate
        dateFormatter.dateFormat = "MM/dd/yyyy"

        return dateFormatter.string(from: date as Date)
    }
    
    func fileDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "M-d-yyyy"
        return dateFormatter.string(from: date as Date)
    }

    func createError(domain: String, code: Int, text: String) -> Error {
        let userInfo: [String : String] = [NSLocalizedDescriptionKey: text]
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }

    func fetch(type: DataType, completion: @escaping (_ results: [String: [String]]?, _ csv: String?, _ error: NSError?) -> Void) {
        let confirmUS = "time_series_covid19_confirmed_US.csv"
        let deathUS = "time_series_covid19_deaths_US.csv"

        let confirmGlobal = "time_series_covid19_confirmed_global.csv"
        let deathGlobal = "time_series_covid19_deaths_global.csv"
        let recoveredGlobal = "time_series_covid19_recovered_global.csv"

        var confirm: [String] = [String]()
        var death: [String] = [String]()
        var recovered: [String] = [String]()
        var resultData: [String: [String]] = [String: [String]]()

        switch type {
        case .confirmglobal:
            fetchData(url: "\(JHU_URL)\(confirmGlobal)") { (confirmData, csv, error) in
                if error != nil {
                    completion(nil, nil, error)
                } else {
                    if confirmData != nil {
                        confirm = confirmData as! [String]
                        resultData["confirm"] = confirm
                    }
                    completion(resultData, csv, error)
                }
            }

        case .deathglobal:
            fetchData(url: "\(JHU_URL)\(deathGlobal)") { (confirmData, csv, error) in
                if error != nil {
                    completion(nil, nil, error)
                } else {
                    if confirmData != nil {
                        death = confirmData as! [String]
                        resultData["death"] = death
                    }
                    completion(resultData, csv, error)
                }
            }

        case .recoveredglobal:
            fetchData(url: "\(JHU_URL)\(recoveredGlobal)") { (confirmData, csv, error) in
                if error != nil {
                    completion(nil, nil, error)
                } else {
                    if confirmData != nil {
                        recovered = confirmData as! [String]
                        resultData["recovered"] = recovered
                    }
                    completion(resultData, csv, error)
                }
            }

        case .confirmus:
            fetchData(url: "\(JHU_URL)\(confirmUS)") { (confirmData, csv, error) in
                if error != nil {
                    completion(nil, nil, error)
                } else {
                    if confirmData != nil {
                        confirm = confirmData as! [String]
                        resultData["confirm"] = confirm
                    }
                    completion(resultData, csv, error)
                }
            }

        case .deathus:
            fetchData(url: "\(JHU_URL)\(deathUS)") { (confirmData, csv, error) in
                if error != nil {
                    completion(nil, nil, error)
                } else {
                    if confirmData != nil {
                        death = confirmData as! [String]
                        resultData["death"] = death
                    }
                    completion(resultData, csv, error)
                }
            }
        }
    }
}
