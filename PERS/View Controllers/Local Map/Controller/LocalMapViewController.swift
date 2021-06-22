//
//  LocalMapViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 10/06/2021.
//

import UIKit
//import GoogleMaps

class LocalMapViewController: UIViewController {
    //MARK: IBOUTLET'S
    @IBOutlet weak var map: UIView!
    //MARK: VARIABLE'S
   // var locationManager = CLLocationManager()
     //var mapMarkArray:[MapMarkerModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        map.delegate = self
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        setupGoogleMap()
    }
}
//
////MARK:- HELPING METHOD'S
//extension LocalMapViewController{
//    func setupGoogleMap() {
//        do {
//            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
//                self.map.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
//            } else {
//                NSLog("Unable to find style.json")
//            }
//        } catch {
//            NSLog("One or more of the map styles failed to load. \(error)")
//        }
//    }
//    //    func findMarker(markerTitle:String) {
//    //      for i in mapMarkArray{
//    //        if i.title == markerTitle{
//    //          selectedMarkerData = i
//    //          self.performSegue(withIdentifier: "MarkerDetailSegue", sender: nil)
//    //        }
//    //      }
//    //    }
//}
//
//// MARK:- GOOGLE MAP DELEGATE'S
//extension LocalMapViewController: CLLocationManagerDelegate ,GMSMapViewDelegate{
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        //findMarker(markerTitle: marker.snippet!)
//        return true
//    }
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        guard status == .authorizedWhenInUse else {
//            return
//        }
//        locationManager.startUpdatingLocation()
//        map.isMyLocationEnabled = true
//    }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.first else {
//            return
//        }
//        map.camera = GMSCameraPosition(target: location.coordinate, zoom: 14.0, bearing: 0, viewingAngle: 0)
//        // Call Location Api
//        //self.GetAllPlansApi(latitude: String(location.coordinate.latitude), longitude: String(location.coordinate.longitude))
//        //locationManager.stopUpdatingLocation()
//    }
//    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
//        print(mapView)
//    }
//}
