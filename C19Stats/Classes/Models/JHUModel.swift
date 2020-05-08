//
//  JHUModel.swift
//  C19Stats
//
//  Created by Gene Backlin on 5/7/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

enum USFormat: Int {
    case uid = 0
    case iso2 = 1
    case iso3 = 2
    case code3 = 3
    case fips = 4
    case county = 5
    case provinceState = 6
    case countryRegion = 7
    case latitude = 8
    case longitude = 9
}

enum GlobalFormat: Int {
    case provinceState = 0
    case countryRegion = 1
    case latitude = 2
    case longitude = 3
}

import Foundation

struct JHUModel {
    var uid: String
    var iso2: String
    var iso3: String
    var code3: String
    var fips: String
    var county: String
    var provinceState: String
    var countryRegion: String
    var latitude: String
    var longitude: String
    var dateString: String
    var latestTotal: String
    var resultType: String
}
