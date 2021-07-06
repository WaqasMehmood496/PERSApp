//
//  LocalMapViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 10/06/2021.
//

import UIKit
import GoogleMaps
import Firebase

class LocalMapViewController: UIViewController {
    //MARK: IBOUTLET'S
    
    @IBOutlet weak var Map: GMSMapView!
    //MARK: VARIABLE'S
    ///Google map and location variables
    var locationManager = CLLocationManager()
    var curentPosition = CLLocation()
    var zoomLevel: Float = 12.0
    let geocoder = GMSGeocoder()
    var isLocationGet = false
    ///Firebase Valiablesa
    var mAuth = Auth.auth()
    var ref: DatabaseReference!
    // var mapMarkArray:[MapMarkerModel] = []
    
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
        for video in videos{
            if let videoLat = CLLocationDegrees(video.videoLatitude) , let videoLng = CLLocationDegrees(video.videoLongitude){
                let videoLocation = CLLocation(latitude: videoLat, longitude: videoLng)
                let distance = self.curentPosition.distance(from: videoLocation) / 1000
                if(distance <= 1609){
                    // place mark on google map
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: videoLat, longitude: videoLng))
                    marker.map = self.Map
                    marker.icon = #imageLiteral(resourceName: "Location")
                    
                }
            }
        }//End For loop
    }
    //    func findMarker(markerTitle:String) {
    //      for i in mapMarkArray{
    //        if i.title == markerTitle{
    //          selectedMarkerData = i
    //          self.performSegue(withIdentifier: "MarkerDetailSegue", sender: nil)
    //        }
    //      }
    //    }
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
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  zoom: zoomLevel)
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

// MARK:- FIREBASE METHODS EXTENSION
extension LocalMapViewController{
    // GET ALL VIDEOS FROM FIREBASE DATABASE
    func getAllVideosInMyArea() {
        if Connectivity.isConnectedToNetwork(){
            self.ref.child("Videos").observe(.value) { (snapshot) in
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
            PopupHelper.showAlertControllerWithError(forErrorMessage: "Internet is unavailable please check your connection", forViewController: self)
        }//End Connectity Check Statement
    }// End get favorite method
    
    
}
