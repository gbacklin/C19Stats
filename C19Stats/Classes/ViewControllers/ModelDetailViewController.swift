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
    var regions: [JHUModel]?
    
    var mapItems: [MKMapItem] = [MKMapItem]()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if model != nil {
            var models = [JHUModel]()
            models.append(model!)
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
            addAnnotations(regions: models)
        } else {
            if regions != nil {
                title = regions![0].provinceState
                dateLabel.text = regions![0].dateString
                totalLabel.text = regions![0].resultType

                let latitude: CLLocationDegrees = regions![0].latitude.toDouble()!
                let longitude: CLLocationDegrees = regions![0].longitude.toDouble()!
                let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
                mapView.centerToLocation(initialLocation, regionRadius: 300000)
                addAnnotations(regions: regions!)
            }
        }
    }
    
    func addAnnotations(regions: [JHUModel]) {
        for region in regions {
            let annotation = MKPointAnnotation()
            let latitude: CLLocationDegrees = region.latitude.toDouble()!
            let longitude: CLLocationDegrees = region.longitude.toDouble()!

            let centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude:longitude)
            annotation.coordinate = centerCoordinate
            if region.county.count > 0 {
                annotation.title = region.county
            } else {
                annotation.title = region.provinceState
            }
            annotation.subtitle = "\(region.latestTotal)"
            mapView.addAnnotation(annotation)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowAnnotationDetail" {
            let annotationView: MKAnnotationView? = sender as? MKAnnotationView
            
            if let annotation: CustomAnnotation = annotationView!.annotation as? CustomAnnotation {
                let controller: CustomAnnotationCalloutViewController = segue.destination as! CustomAnnotationCalloutViewController
                controller.popoverPresentationController!.delegate = self
                controller.popoverPresentationController?.sourceView = sender as? UIView
                controller.preferredContentSize = CGSize(width: 150, height: 100)

                controller.annotation = annotation
            }
        }
    }

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

extension ModelDetailViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        debugPrint("popoverPresentationControllerDidDismissPopover")
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension ModelDetailViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
        -> MKAnnotationView? {
            
            let identifier = "marker"
            var view: MKMarkerAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            //let rightButton = UIButton(type: .close)
            view.rightCalloutAccessoryView = UIView()
            view.canShowCallout = true
            
            return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let _: CustomAnnotation = view.annotation as? CustomAnnotation {
            performSegue(withIdentifier: "ShowAnnotationDetail", sender: view)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }

}


