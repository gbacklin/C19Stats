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
    
    var selectedDataType: DataType?
    var headerArray: [String] = [String]()
    var lastColumn = 0
    var reportingDate = ""

    func fetchData(url: String, type: DataType, completion: @escaping (_ results: Any?,_ csv: String?,_ models: [JHUModel]?,_ regions: [String: [JHUModel]]?, _ error: NSError?) -> Void) {
        // Fetch data...
        headerArray.removeAll()
        lastColumn = 0
        reportingDate = ""
        Network.shared.getCSV(url: url) { [weak self] (results, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, nil, nil, nil, error)
                }
            } else {
                if let rawData: String = results as? String {
                    var parsedData: [String]?
                    parsedData = rawData.split{$0 == "\r\n"}.map(String.init)
                    if parsedData!.count < 2 {
                        parsedData = rawData.split{$0 == "\n"}.map(String.init)
                    }
                    let modelData: [JHUModel]? = self!.parseArray(csvArray: parsedData!, type: type)
                    
                    self!.headerArray.removeAll()
                    self!.lastColumn = 0
                    self!.reportingDate = ""

                    let regionData: [String: [JHUModel]]? = self!.parseRegionArray(csvArray: parsedData!, type: type)

                    //let parsedData = rawData.split(separator: "\n")
                    var dataArray: [String] = [String]()
                    for data in parsedData! {
                        dataArray.append(data)
                    }
                    DispatchQueue.main.async {
                        completion(dataArray, rawData, modelData, regionData, nil)
                    }
                } else {
                    let error: NSError = self!.createError(domain: NSURLErrorDomain, code: -1955, text: "The results from the query were nil") as NSError
                    DispatchQueue.main.async {
                        completion(nil, nil, nil, nil, error)
                    }
                }
            }
        }
    }
    
    // MARK: - Utility methods
    
    func parseRecord(csv: String, type: DataType, delim: Character?) -> JHUModel? {
        var result: JHUModel?
        var csvArray: [String]?
        
        if delim != nil {
            csvArray = csv.split{$0 == delim!}.map(String.init)
        } else {
            csvArray = csv.split{$0 == ","}.map(String.init)
        }
        switch type {
        case .confirmus, .deathus:
            if headerArray.count < 1 {
                headerArray = csvArray!
                lastColumn = headerArray.count-1
                reportingDate = headerArray[lastColumn]
            } else {
                if let record = csvArray {
                    let dataType = (type == .confirmus) ? "Confirmed US" : "Deaths US"
                    let index = Int(record[USFormat.uid.rawValue])
                    if  index! < 1000 {
                        result = JHUModel(uid: record[USFormat.uid.rawValue],
                                          iso2: record[USFormat.iso2.rawValue],
                                          iso3: record[USFormat.iso3.rawValue],
                                          code3: record[USFormat.code3.rawValue],
                                          fips: record[USFormat.fips.rawValue],
                                          county: "",
                                          provinceState: record[USFormat.provinceState.rawValue-1],
                                          countryRegion: record[USFormat.countryRegion.rawValue-1],
                                          latitude: record[USFormat.latitude.rawValue-1],
                                          longitude: record[USFormat.longitude.rawValue-1],
                                          dateString: reportingDate,
                                          latestTotal: record[record.count-1], resultType: dataType)
                    } else {
                        result = JHUModel(uid: record[USFormat.uid.rawValue],
                                          iso2: record[USFormat.iso2.rawValue],
                                          iso3: record[USFormat.iso3.rawValue],
                                          code3: record[USFormat.code3.rawValue],
                                          fips: record[USFormat.fips.rawValue],
                                          county: record[USFormat.county.rawValue],
                                          provinceState: record[USFormat.provinceState.rawValue],
                                          countryRegion: record[USFormat.countryRegion.rawValue],
                                          latitude: record[USFormat.latitude.rawValue],
                                          longitude: record[USFormat.longitude.rawValue],
                                          dateString: reportingDate,
                                          latestTotal: record[record.count-1], resultType: dataType)
                    }
                }
            }
        case .confirmglobal, .deathglobal, .recoveredglobal:
            if headerArray.count < 1 {
                headerArray = csvArray!
                lastColumn = headerArray.count-1
                reportingDate = headerArray[lastColumn]
            } else {
                if let record = csvArray {
                    var dataType = "Confirmed Global"
                    if type == .deathglobal {
                        dataType = "Death Global"
                    } else if type == .recoveredglobal {
                        dataType = "Recovered Global"
                    }
                    if record.count < headerArray.count {
                        result = JHUModel(uid: "",
                                          iso2: "",
                                          iso3: "",
                                          code3: "",
                                          fips: "",
                                          county: "",
                                          provinceState: "",
                                          countryRegion: record[GlobalFormat.countryRegion.rawValue-1],
                                          latitude: record[GlobalFormat.latitude.rawValue-1],
                                          longitude: record[GlobalFormat.longitude.rawValue-1],
                                          dateString: reportingDate,
                                          latestTotal: record[record.count-1], resultType: dataType)
                    } else {
                        if record[GlobalFormat.provinceState.rawValue].count < 1 {
                            debugPrint(record)
                        }
                        result = JHUModel(uid: "",
                                          iso2: "",
                                          iso3: "",
                                          code3: "",
                                          fips: "",
                                          county: "",
                                          provinceState: record[GlobalFormat.provinceState.rawValue],
                                          countryRegion: record[GlobalFormat.countryRegion.rawValue],
                                          latitude: record[GlobalFormat.latitude.rawValue],
                                          longitude: record[GlobalFormat.longitude.rawValue],
                                          dateString: reportingDate,
                                          latestTotal: record[record.count-1], resultType: dataType)
                    }
                }
            }
        }
        return result
    }
    
    func parseArray(csvArray: [String], type: DataType) -> [JHUModel]? {
        var result: [JHUModel]?
        for csv in csvArray {
            if let rec = parseRecord(csv: csv, type: type, delim: ",") {
                if result == nil {
                    result = [JHUModel]()
                }
                result?.append(rec)
            }
        }
        return result
    }

    func parseRegionArray(csvArray: [String], type: DataType) -> [String: [JHUModel]]? {
        var result: [String: [JHUModel]]?
        for csv in csvArray {
            if let rec = parseRecord(csv: csv, type: type, delim: ",") {
                if result == nil {
                    result = [String: [JHUModel]]()
                }
                switch type {
                case .confirmus, .deathus:
                    let key = rec.provinceState
                    if var localRegions = result![key] {
                        localRegions.append(rec)
                        result![key] = localRegions
                    } else {
                        var localRegions: [JHUModel] = [JHUModel]()
                        localRegions.append(rec)
                        result![key] = localRegions
                    }
                case .confirmglobal, .deathglobal, .recoveredglobal:
                    let key = rec.countryRegion
                    if var localRegions = result![key] {
                        localRegions.append(rec)
                        result![key] = localRegions
                    } else {
                        var localRegions: [JHUModel] = [JHUModel]()
                        localRegions.append(rec)
                        result![key] = localRegions
                    }
                }
            }
        }
        return result
    }

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

    func fetch(type: DataType, completion: @escaping (_ results: [String]?, _ csv: String?, _ models: [JHUModel]?, _ regions: [String: [JHUModel]]?, _ error: NSError?) -> Void) {
        let confirmUS = "time_series_covid19_confirmed_US.csv"
        let deathUS = "time_series_covid19_deaths_US.csv"

        let confirmGlobal = "time_series_covid19_confirmed_global.csv"
        let deathGlobal = "time_series_covid19_deaths_global.csv"
        let recoveredGlobal = "time_series_covid19_recovered_global.csv"

        switch type {
        case .confirmglobal:
            fetchData(url: "\(JHU_URL)\(confirmGlobal)", type: type) { (data, csv, dataModels, regionModels, error) in
                if error != nil {
                    completion(nil, nil, nil, nil, error)
                } else {
                    completion(data as? [String], csv, dataModels, regionModels, error)
                }
            }
        case .deathglobal:
            fetchData(url: "\(JHU_URL)\(deathGlobal)", type: type) { (data, csv, dataModels, regionModels, error) in
                if error != nil {
                    completion(nil, nil, nil, nil, error)
                } else {
                    completion(data as? [String], csv, dataModels, regionModels, error)
                }
            }
        case .recoveredglobal:
            fetchData(url: "\(JHU_URL)\(recoveredGlobal)", type: type) { (data, csv, dataModels, regionModels, error) in
                if error != nil {
                    completion(nil, nil, nil, nil, error)
                } else {
                    completion(data as? [String], csv, dataModels, regionModels, error)
                }
            }
        case .confirmus:
            fetchData(url: "\(JHU_URL)\(confirmUS)", type: type) { (data, csv, dataModels, regionModels, error) in
                if error != nil {
                    completion(nil, nil, nil, nil, error)
                } else {
                    completion(data as? [String], csv, dataModels, regionModels, error)
                }
            }
        case .deathus:
            fetchData(url: "\(JHU_URL)\(deathUS)", type: type) { (data, csv, dataModels, regionModels, error) in
                if error != nil {
                    completion(nil, nil, nil, nil, error)
                } else {
                    completion(data as? [String], csv, dataModels, regionModels, error)
                }
            }
        }
    }
    
    func saveResults(dataType: DataType, completion: @escaping (_ path: String, _ filename: String, _ csv: String?, _ models: [JHUModel]?, _ regions: [String: [JHUModel]]?, _ error: NSError?, _ message: String?) -> Void) {
        selectedDataType = dataType
        JHUData.shared.fetch(type: dataType) { (results, csv, models, regions, error) in
            let documents: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            var filename: String = ""
            
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
            // Perform Segue to Save or display results
            //self.outputFilename = documents.appendingPathComponent(filename)
            //self.outputCSVData = csv
            //self.modelData = models
            //(confirm as NSArray).write(toFile: self.outputFilename, atomically: true)
            //self.saveFile(path: self.outputFilename, data: csv!)
            let message = "There were \(results!.count) records retrieved."
            completion(documents.appendingPathComponent(filename), filename, csv, models, regions, error, message)
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
