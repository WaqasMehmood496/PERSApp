//
//  MapsViewController.swift
//  OnSaloon
//
//  Created by Waqas on 16/04/2021.
//

import UIKit
//import GoogleMaps

class MapsViewController: UIViewController {
    //MARK: IBOUTLET'S
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var lblAddress: UITextField!
    //MARK: VARIABLE'S
//    var locationManager = CLLocationManager()
//    var location = LocationModel()
//    var curentPosition: CLLocationCoordinate2D!
//    var zoomLevel: Float = 18.0
//    var delagate:PassDataDelegate?
//
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setupGoogleMapStyle()
//        self.setupGoogleMapFunctionality()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: IBACTION'S
    @IBAction func doneBtnPressed(_ sender:Any){
//        delagate?.passCurrentLocation(data: self.location)
//        self.dismiss(animated: true, completion: nil)
    }
}
//
////MARK:- HELPING METHOD'S
//extension MapsViewController{
//    // THIS METHOD WILL CHANGE GOOGLE MAP STYLE INTO DARK VIEW
//    func setupGoogleMapStyle() {
//        do {
//            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
//                self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
//                
//            } else {
//                NSLog("Unable to find style.json")
//            }
//        } catch {
//            NSLog("One or more of the map styles failed to load. \(error)")
//        }
//    }
//    // THIS METHOD WILL GET THE CURRENT LOCATION AND SET THE POINTER TO IT
//    func setupGoogleMapFunctionality() {
//        locationManager = CLLocationManager()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestAlwaysAuthorization()
//        locationManager.distanceFilter = 50
//        locationManager.startUpdatingLocation()
//        locationManager.delegate = self
//    }
//    //THIS METHOD WILL PLACE A MARK ON USER CURRENT LOCATION
//    func placeMarkOnGoogleMap(location:CLLocation,address:String) {
//        let marker = GMSMarker(position: location.coordinate)
//        marker.title = address
//        self.lblAddress.text = address
//        marker.map = self.mapView
//        marker.icon = UIImage(named: "Location")
//    }
//    // THIS METHOD WILL SAVE USER CURRENT LOCATION DATA INTO OBJECT
//    func saveLocationDataInModel(location:CLLocation,address:GMSAddress,userAddress:String) {
//        self.location.address_name = address.locality
//        self.location.address = userAddress
//        self.location.street_address_1 = address.subLocality
//        self.location.street_address_2 = address.locality
//        self.location.city = address.administrativeArea
//        self.location.zipcode = address.postalCode
//        self.location.address_lat = location.coordinate.latitude
//        self.location.address_lng = location.coordinate.longitude
//    }
//}
////MARK:- LOCATION MANAGER DELEGATES METHOD'S
//extension MapsViewController: CLLocationManagerDelegate {
//    // THIS DELEGATE METHOD WILL HANDLE USER CURRENT INCOMMING LOCATION
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location: CLLocation = locations.last!
//        print("Location: \(location)")
//        let geocoder = GMSGeocoder()
//        geocoder.reverseGeocodeCoordinate(location.coordinate){response , error in
//            guard let address: GMSAddress = response?.firstResult()else{return}
//            let  userAddress = address.lines!.joined(separator: "\n")
//            self.placeMarkOnGoogleMap(location: location, address: userAddress)
//            self.saveLocationDataInModel(location: location, address: address, userAddress: userAddress)
//        }
//    }
//    // HANDLING USER AUTHORIZATION
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        switch status {
//        case .restricted:
//            print("Location access was restricted.")
//        case .denied:
//            print("User denied access to location.")
//            // Display the map using the default location.
//            PopupHelper.alertWithAppSetting(title: "Alert", message: "Please enable your location to get your current location", controler: self)
//        case .notDetermined:
//            print("Location status not determined.")
//        case .authorizedAlways: fallthrough
//        case .authorizedWhenInUse:
//            print("Location status is OK.")
//        @unknown default:
//            break
//        }
//    }
//    // HANDLING LOCATION MANAGER ERROR
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        locationManager.stopUpdatingLocation()
//        print("Error: \(error)")
//    }
//}
//
////MARK:- GOOGLE DELEGATES EXTENSION
//extension MapsViewController:GMSMapViewDelegate{
//    // THIS METHOD WILL GET SELECTED LOCATION CORDINATES AND LOCATION INFO
//    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        mapView.clear()
//        print("Lat: \(coordinate.latitude) & Long: \(coordinate.longitude)")
//        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        self.curentPosition = position
//        let geocoder = GMSGeocoder()
//        geocoder.reverseGeocodeCoordinate(coordinate){response , error in
//            guard let address: GMSAddress = response?.firstResult()else{return}
//            let  userAddress = address.lines!.joined(separator: "\n")
//            let marker = GMSMarker(position: position)
//            marker.title = userAddress
//            self.lblAddress.text = userAddress
//            marker.map = mapView
//            marker.icon = #imageLiteral(resourceName: "marker")
//            self.location.address_name = address.locality
//            self.location.address = userAddress
//            self.location.street_address_1 = address.subLocality
//            self.location.street_address_2 = address.locality
//            self.location.city = address.administrativeArea
//            self.location.zipcode = address.postalCode
//            self.location.address_lat = coordinate.latitude
//            self.location.address_lng = coordinate.longitude
//        }
//    }
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        mapView.selectedMarker = marker
//        let camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: zoomLevel)
//        let update = GMSCameraUpdate.setCamera(camera)
//        mapView.animate(with: update)
//        return true
//    }
//    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
//        self.lblAddress.text = marker.title
//        self.curentPosition = marker.position
//        delagate?.passCurrentLocation(data: self.location)
//        self.dismiss(animated: true, completion: nil)
//    }
//    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        //reverseGeocodeCoordinate(position.target)
//    }
//    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
//        
//    }
//    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
//        let geocoder = GMSGeocoder()
//        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
//            guard let address = response?.firstResult(), let lines = address.lines else {
//                return
//            }
//            self.lblAddress.text = lines.joined(separator: "\n")
//            self.curentPosition = address.coordinate
//            UIView.animate(withDuration: 0.25) {
//                self.view.layoutIfNeeded()
//            }
//            self.mapView.animate(toLocation: address.coordinate)
//        }
//    }
//}
