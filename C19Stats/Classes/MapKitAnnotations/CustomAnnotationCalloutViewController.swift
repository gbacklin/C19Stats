//
//  CustomAnnotationCalloutViewController.swift
//  MKDemo
//
//  Created by Gene Backlin on 9/17/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotationCalloutViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var annotation: CustomAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let title = annotation?.title {
            titleLabel.text = title
        } else {
            titleLabel.text = ""
        }
        if let subtitle = annotation?.subtitle {
            subtitleLabel.text = subtitle
        } else {
            subtitleLabel.text = ""
        }
        if let count = annotation?.count {
            countLabel.text = count
        } else {
            countLabel.text = ""
        }
        
    }
}
