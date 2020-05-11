//
//  CustomAnnotation.swift
//  C19Stats
//
//  Created by Gene Backlin on 5/10/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    //@objc dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var subtitle: String?
    var count: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }


}
