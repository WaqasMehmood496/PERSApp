//
//  LocalMapViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 10/06/2021.
//

import UIKit
import GoogleMaps
import Firebase
import SwiftUI
import SemiModalViewController

class LocalMapViewController: UIViewController {
    
    //MARK: IBOUTLET'S
    @IBOutlet weak var Map: GMSMapView!
    // CONSTANTS
    let controllerXYPosition: CGFloat = 0.0
    let geocoder = GMSGeocoder()
    var myNearestVideos = [VideosModel]()
    
    // VARIABLE'S
    var locationManager = CLLocationManager()
    var curentPosition = CLLocation()
    var zoomLevel: Float = 12.0
    var isLocationGet = false
    var mAuth = Auth.auth()
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.mapStyleSetup()
        self.userLocationSetup()
    }
}

//MARK:- HELPING METHOD'S
extension LocalMapViewController{
    func mapStyleSetup() {
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                self.Map.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                self.Map.isMyLocationEnabled = true
                self.Map.delegate = self
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    func userLocationSetup() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func checkMyNearestVideos(videos: [VideosModel]) {
        for (index,video) in videos.enumerated(){
            if let videoLat = CLLocationDegrees( video.videoLatitude ) , let videoLng = CLLocationDegrees(video.videoLongitude) {
                let videoLocation = CLLocation(latitude: videoLat, longitude: videoLng)
                let distance = self.curentPosition.distance(from: videoLocation) / 1000
                if( distance <= 1609 ) {
                    // place mark on google map
                    let marker = GMSMarker(position: CLLocationCoordinate2D (latitude: videoLat, longitude: videoLng))
                    marker.map = self.Map
                    marker.icon = #imageLiteral(resourceName: "Location")
                    marker.accessibilityHint = String(index)
                    myNearestVideos.append(video)
                }
            }
        }//End For loop
    }
}


// MARK:- LOCATION DELEGATES METHOD'S EXTENSION
extension LocalMapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if isLocationGet{
            
        }else{
            isLocationGet = true
            let location: CLLocation = locations.last!
            print("Location: \(location)")
            let camera = GMSCameraPosition.camera (
                withLatitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                zoom: zoomLevel
            )
            self.Map.camera = camera
            self.Map.animate(to: camera)
            self.curentPosition = location
            self.getAllVideosInMyArea()
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            PopupHelper.alertWithAppSetting(title: "Alert", message: "Please enable your location", controler: self)
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            print("Unknown case found")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension LocalMapViewController:GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //mapView.clear()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let controller = self.storyboard!.instantiateViewController(identifier: "PlayerViewController") as! PlayerViewController
        controller.isVideoSelectedFromMap = true
        if let selectedVideo = Int(marker.accessibilityHint!) {
            controller.MyAreaVideos.append(self.myNearestVideos[selectedVideo])
            DispatchQueue.main.async {
                self.tabBarController!.present( controller, animated: true, completion: nil )
            }
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            // 3
            //    self.lblAddress.text = lines.joined(separator: "\n")
            //    self.curentPosition = address.coordinate
            // 4
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
            self.Map.animate(toLocation: address.coordinate)
        }
    }
}

// MARK:- FIREBASE METHODS EXTENSION
extension LocalMapViewController{
    // GET ALL VIDEOS FROM FIREBASE DATABASE
    func getAllVideosInMyArea() {
        if Connectivity.isConnectedToNetwork(){
            self.ref.child(Constant.videosTable).observe(.value) { (snapshot) in
                if(snapshot.exists()) {
                    var tempArray = [VideosModel]()
                    let array:NSArray = snapshot.children.allObjects as NSArray
                    for obj in array {
                        let snapshot:DataSnapshot = obj as! DataSnapshot
                        if var childSnapshot = snapshot.value as? [String : AnyObject]
                        {
                            childSnapshot[Constant.id] = snapshot.key as String as AnyObject
                            let videos = VideosModel(dic: childSnapshot as NSDictionary)
                            if let video = videos{
                                tempArray.append(video)
                            }
                        }
                    }// End For loop
                    self.checkMyNearestVideos(videos: tempArray)
                }else{
                    print("Data not found")
                }// End Snapshot if else statement
            }
        }else{
            PopupHelper.showAlertControllerWithError(forErrorMessage: Constant.internetMsg, forViewController: self)
        }//End Connectity Check Statement
    }// End get favorite method
    
    
}
