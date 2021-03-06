//
//  MapVC.swift
//  Weather Central
//
//  Created by George Bauer on 10/19/17.
//  Copyright © 2017-2020 GeorgeBauer. All rights reserved.
//

import UIKit
import MapKit

protocol MapVCdelegate: class {
    func mapVCreturn(_ controller: MapVC, returnType: LocationSelectionType, stationID: String, lat: Double, lon: Double)    //delegate
    // mapReturnType      stationIDFromMap = ""   latFromMap = 0.0     lonFromMap = 0.0
}

//MARK: ------- class MapVC (MapViewController) ------
class MapVC: UIViewController, MKMapViewDelegate {
    weak var delegate: MapVCdelegate?          //delegate
    //MARK: ---- properties ----
    let longPressSec = 1.5
    var mapReturnType = LocationSelectionType.none

    // Set by Caller
    var searchLat  = 0.0
    var searchLon  = 0.0
    var latDelta   = 0.18
    var lonDelta   = 0.18
    var searchType = LocationSelectionType.none
    var searchName = ""
    var stations   = [Station]()

    // Return to Caller delegate
    var latFromMap = 0.0
    var lonFromMap = 0.0
    var stationIDFromMap = ""

    @IBAction func btnScaleTap(_ sender: UIButton) {
        zoomMap(1.001)
    }

    //MARK:---- @IBOutlets ----
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblSelected: UILabel!
    @IBOutlet weak var btnSave: UIButton!

    //MARK:---- Overrides ----
    // ---- viewDidLoad ----
    override func viewDidLoad() {
        super.viewDidLoad()

        mapReturnType = .none        // we have not yet picked anything
        btnSave.isEnabled = false
        //plotMap(lat: searchLat, lon: searchLon, latDelt: latDelta, lonDelt: lonDelta)
        mapView.showsUserLocation = true

        var info = "\(searchType.rawValue) search\nThis is the center of the search for weather stations close to \(searchName).\n"
        info += "\(formatLatLon(lat: searchLat, lon: searchLon, places: 3))"
        addMyAnnotation(title: searchName, subtitle: "searching from here", lat: searchLat, lon: searchLon, info: info, pinColor: UIColor.black, backgroundColor: nil)

        addAnnotations(stations: stations)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction(gestureRecognizer:)))
        longPress.minimumPressDuration = longPressSec
        mapView.addGestureRecognizer(longPress)

        let scale = MKScaleView(mapView: mapView)
        scale.scaleVisibility = .visible            // always visible
        mapView.addSubview(scale)

        plotMap(lat: searchLat, lon: searchLon, latDelt: latDelta, lonDelt: lonDelta)
    }//end func viewDidLoad

    //MARK: ---- @IBActions ----
    @IBAction func btnSave(_ sender: UIButton) {
        let stationID = lblSelected.text ?? "??"
        delegate?.mapVCreturn(self, returnType: mapReturnType, stationID: stationID, lat: latFromMap, lon: lonFromMap) //delegate
        navigationController?.popViewController(animated: true)
    }

    @IBAction func btnZoomOut(_ sender: UIButton) {
        zoomMap(1.5)
    }

    @IBAction func btnZoomIn(_ sender: UIButton) {
        zoomMap(1.0/1.5)
    }

    //MARK:---- General funcs ----

    //---- zoomMap - increase (or decrease if <1) map region by a factor
    func zoomMap(_ factor: Double) {
        let latNow = mapView.region.center.latitude
        let lonNow = mapView.region.center.longitude
        latDelta = latDelta * factor
        latDelta = min(latDelta, 180)
        latDelta = max(latDelta, 0.02)
        lonDelta = lonDelta * factor
        lonDelta = min(lonDelta, 180)
        lonDelta = max(lonDelta, 0.02)
        plotMap(lat: latNow, lon: lonNow, latDelt: latDelta, lonDelt: lonDelta)
    }

    // ---- Calculates region;  displays Map ----
    func plotMap(lat: Double, lon: Double, latDelt: Double, lonDelt: Double) {
        let latitude:  CLLocationDegrees = lat
        let longitude: CLLocationDegrees = lon
        let latDelta: CLLocationDegrees = latDelt
        let lonDelta: CLLocationDegrees = lonDelt

        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.showsScale = true

        mapView.setRegion(region, animated: true)
    }//end func

    // ---- Add all the StationPin annotations from stations array ----
    func addAnnotations(stations:[Station]) {
        for station in stations {
            let subtitle:String
            if station.neighborhood != "" {
                subtitle = station.neighborhood
            } else {
                subtitle = station.city
            }
            var info = station.type + "\n"
            if station.neighborhood != "" {
                info += station.neighborhood + "\n"
            }
            info += station.city + ", " + station.state + "\n\(formatLatLon(lat: station.lat, lon: station.lon, places: 3))"
            let pinColor = station.type == "pws" ? UIColor.blue : UIColor.red
            addMyAnnotation(title: station.id, subtitle: subtitle, lat: station.lat, lon: station.lon, info: info, pinColor: pinColor, backgroundColor: nil)
        }
    }
    
    // ---- Add a single StationPin annotation to the map ----
    func addMyAnnotation(title: String, subtitle: String, lat: Double, lon:Double,
                         info: String, pinColor: UIColor, backgroundColor: UIColor?) {
        let ann = StationPin(title: title, subtitle: subtitle,
                             coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), info: info,
                             pinColor: pinColor, backgroundColor: backgroundColor)
        mapView.addAnnotation(ann)
    }//end func
    
    @objc func longPressAction(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        latFromMap = coordinate.latitude
        lonFromMap = coordinate.longitude

//        let annotation = MKPointAnnotation()  // to add an annotation at touchPoint
//        annotation.coordinate = coordinate
//        annotation.title = "New Place"
//        annotation.subtitle = "User-defined"
//        mapView.addAnnotation(annotation)

        //showAlert(title: "Attention", message: "This Lat/Lon will be entered.")
        mapReturnType = .latlon
        lblSelected.text = formatLatLon(lat: latFromMap, lon: lonFromMap, places: 3)
        btnSave.isEnabled = true
    }

    // Show a Popup message with OK/Cancel choices - Never Called
    func showAlert(title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (result : UIAlertAction) -> Void in
            print("showAlert: Cancel")
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            print("showAlert: OK")
            self.mapReturnType = .latlon
            guard (self.navigationController?.popViewController(animated:true)) != nil else {
                print("\n😡No navigationController")
                return
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }//end func


    //MARK:---- mapView delegates ----

    // ---- built-in "viewFor" is run whenever an annotation is to be displayed ----
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 1 Define a reuse identifier. This will be used to ensure we reuse annotation views as much as possible.
        let identifier = "StationPin"
        // 2 Check whether the annotation we're creating a view for is one of our StationPin objects.
        if annotation is StationPin {
            // 3 Try to dequeue an annotation view from the map view's pool of unused views.
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            
            if annotationView == nil {
                //4 If it isn't able to find a reusable view, create a new one using MKPinAnnotationView and sets its canShowCallout property to true. This triggers the popup with the city name.
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier) 
                annotationView?.canShowCallout = true
                
                // 5 Create a UIButton using built-in .detailDisclosure type (small blue "i" symbol with a circle around it).
                let btn = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = btn

                let stationPin = annotation as! StationPin

                annotationView?.pinTintColor = stationPin.pinColor
                annotationView?.backgroundColor = stationPin.backgroundColor
            } else {
                // 6 If it can reuse a view, update that view to use a different annotation.
                annotationView?.annotation = annotation
            }
            return annotationView
        }//endif is StationPin
        
        // 7 If the annotation isn't from a StationPin, it must return nil so iOS uses a default view.
        return nil
    }//end func

    //------ Handles detailDisclosure button on stationPin ------
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let stationPin = view.annotation as! StationPin
        let title = stationPin.title
        let info = stationPin.info
        
        let alertController = UIAlertController(title: title, message: info, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }//end func

    //---- Handles LongPress on Map ----
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let title = view.annotation?.title as? String {
            print("User tapped on annotation with title: \(title)")
            if title != searchName && title != "My Location" {
                stationIDFromMap = title
                lblSelected.text = stationIDFromMap
                mapReturnType = .station
                btnSave.isEnabled = true
            }
        }//endif let title
    }//end func

}//end class MapVC

//MARK: ------- class StationPin ------
// -------- Define datatype "StationPin", which inherits from MKAnnotation --------
class StationPin: NSObject, MKAnnotation {
    var title:      String?
    var subtitle:   String?
    var coordinate: CLLocationCoordinate2D
    var info:       String
    var pinColor:        UIColor
    var backgroundColor: UIColor?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, info: String, pinColor: UIColor, backgroundColor: UIColor?) {
        self.title      = title
        self.subtitle   = subtitle
        self.coordinate = coordinate
        self.info       = info
        self.pinColor   = pinColor
        self.backgroundColor = backgroundColor
    }
}

