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
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
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
    
    func videosWithUploaderRecord(videos:[VideosModel],users:[LoginModel]) {
        for (vindex,video) in videos.enumerated(){
            for (_,user) in users.enumerated(){
                if user.id == video.uploaderID{
                    videos[vindex].userName = user.name
                    videos[vindex].userImage = user.imageURL
                }
            }
        }
        checkMyNearestVideos(videos: videos)
    }
    
    func checkMyNearestVideos(videos:[VideosModel]) {
//        for (index,video) in self.allVideos.enumerated(){
//            if let videoLat = CLLocationDegrees( video.videoLatitude ) , let videoLng = CLLocationDegrees(video.videoLongitude) {
//                let videoLocation = CLLocation(latitude: videoLat, longitude: videoLng)
//                let distance = self.curentPosition.distance(from: videoLocation) / 1000
//                if( distance <= 1609 ) {
//                    // place mark on google map
//                    let marker = GMSMarker(position: CLLocationCoordinate2D (latitude: videoLat, longitude: videoLng))
//                    marker.map = self.Map
//                    marker.icon = #imageLiteral(resourceName: "Location")
//                    marker.accessibilityHint = String(index)
//                    myNearestVideos.append(video)
//                }
//            }
//        }//End For loop
        
        
        
        for (index,video) in videos.enumerated(){
            if let videoLat = CLLocationDegrees( video.videoLatitude ) , let videoLng = CLLocationDegrees(video.videoLongitude) {
                let videoLocation = CLLocation(latitude: videoLat, longitude: videoLng)
                let distance = self.curentPosition.distance(from: videoLocation) / 1000
                if( distance <= 8046.72 ) {
                    myNearestVideos.append(video)
                    placeMarkOnMap(lat: videoLat, lng: videoLng,index: index)
                }
            }
        }//End For loop
    }
    
    func placeMarkOnMap(lat:Double,lng:Double,index:Int) {
        let marker = GMSMarker(position: CLLocationCoordinate2D (latitude: lat, longitude: lng))
        marker.map = self.Map
        marker.icon = #imageLiteral(resourceName: "Location")
        marker.accessibilityHint = String(index)
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
            self.getAllVideos()
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
        let controller = self.storyboard!.instantiateViewController(identifier: "PlayerVC") as! PlayerViewController
        if let selectedVideo = Int(marker.accessibilityHint!) {
            controller.MyAreaVideos = self.myNearestVideos
            controller.SelectedVideo = self.myNearestVideos[selectedVideo]
            //            DispatchQueue.main.async {
            //                self.tabBarController!.present( controller, animated: true, completion: nil )
            //            }
            self.navigationController?.pushViewController(controller, animated: true)
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
    func getAllVideos() {
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
                    //self.checkMyNearestVideos(videos: tempArray)
                    self.getAllUsersRecord(videos: tempArray)
                }else{
                    print("Data not found")
                }// End Snapshot if else statement
            }
        }else{
            PopupHelper.showAlertControllerWithError(forErrorMessage: Constant.internetMsg, forViewController: self)
        }//End Connectity Check Statement
    }// End get favorite method
    
    func getAllUsersRecord(videos:[VideosModel]) {
        if Connectivity.isConnectedToNetwork() {
            if (self.mAuth.currentUser?.uid) != nil{
                self.ref.child("Users").observeSingleEvent(of: .value) { (snapshot) in
                    if(snapshot.exists()) {
                        var allUsers = [LoginModel]()
                        let array:NSArray = snapshot.children.allObjects as NSArray
                        for obj in array {
                            let snapshot:DataSnapshot = obj as! DataSnapshot
                            if var childSnapshot = snapshot.value as? [String : AnyObject] {
                                childSnapshot[Constant.id] = snapshot.key as String as AnyObject
                                let users = LoginModel(dic: childSnapshot as NSDictionary)
                                if let user = users {
                                    allUsers.append(user)
                                }
                            }
                        }// End For loop
                        self.videosWithUploaderRecord(videos: videos, users: allUsers)
                    }// End Snapshot if else statement
                }// End ref Child Completion Block
            }// End Firebase user id
            else{
            }
        }else{
            PopupHelper.showAlertControllerWithError( forErrorMessage: "Internet is unavailable please check your connection", forViewController: self )
        }//End Connectity Check Statement
    }// End get favorite method
}
