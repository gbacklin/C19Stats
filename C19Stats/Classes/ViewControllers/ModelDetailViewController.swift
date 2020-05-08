//
//  ModelDetailViewController.swift
//  C19Stats
//
//  Created by Gene Backlin on 5/8/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

import UIKit
import MapKit

class ModelDetailViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var model: JHUModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.navigationController?.navigationBar.topItem?.title = model?.provinceState
        if model!.county.count > 0 {
            title = "\(String(describing: model!.provinceState)) (\(String(describing: model!.county)))"
        } else {
            title = (model!.provinceState.count > 0) ? model!.provinceState : model!.countryRegion
        }
        dateLabel.text = model!.dateString
        totalLabel.text = model!.resultType
        let latitude: CLLocationDegrees = model!.latitude.toDouble()!
        let longitude: CLLocationDegrees = model!.longitude.toDouble()!
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)

        mapView.centerToLocation(initialLocation)
        addAnnotation()
    }
    
    func addAnnotation() {
        let annotation = MKPointAnnotation()
        let latitude: CLLocationDegrees = model!.latitude.toDouble()!
        let longitude: CLLocationDegrees = model!.longitude.toDouble()!

        let centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude:longitude)
        annotation.coordinate = centerCoordinate
        annotation.title = "\(model!.latestTotal)"
        mapView.addAnnotation(annotation)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

private extension MKMapView {
  func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 150000) {
    let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
