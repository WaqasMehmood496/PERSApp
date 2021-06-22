//
//  HomeViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 09/06/2021.
//

import UIKit
import MobileCoreServices
import Firebase
import MapKit
import AVKit
import JGProgressHUD

class HomeViewController: UIViewController {
    
    //MARK: IBOUTLET'S
    @IBOutlet weak var MyAreaCV: UICollectionView!
    @IBOutlet weak var RecentlyAddedCV: UICollectionView!
    //MARK: VARIABLE'S
    private let spacingIphone:CGFloat = 0.0
    private let spacingIpad:CGFloat = 0.0
    var mAuth = Auth.auth()
    var ref: DatabaseReference!
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var currentAddress = String()
    let image = UIImagePickerController()
    var thumbnail = String()
    var videoArray = [VideosModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.getAllVideo()
        self.collectionViewSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    @IBAction func EmergencyAlertBtnAction(_ sender: Any) {
        showHUDView(hudIV: .indeterminate, text: .process) { (hud) in
            hud.show(in: self.view, animated: true)
            self.getLocation(hud: hud)
        }
    }
}

//MARK:- HELPING METHOD'S EXTENSION
extension HomeViewController{
    // Setup Collection View
    func collectionViewSetup() {
        let layout = UICollectionViewFlowLayout()
        if UIDevice.current.userInterfaceIdiom == .phone{
            layout.sectionInset = UIEdgeInsets(top: spacingIphone, left: spacingIphone, bottom: spacingIphone, right: spacingIphone)
            layout.minimumLineSpacing = spacingIphone
            layout.minimumInteritemSpacing = spacingIphone
        }
        else{
            layout.sectionInset = UIEdgeInsets(top: spacingIpad, left: spacingIpad, bottom: spacingIpad, right: spacingIpad)
            layout.minimumLineSpacing = spacingIpad
            layout.minimumInteritemSpacing = spacingIpad
        }
        
        self.RecentlyAddedCV?.collectionViewLayout = layout
    }
    
    //GET USER CURRENT LOCATION
    func getUserCurrentLocation(completion: (Bool) -> ()) {
        locManager.requestWhenInUseAuthorization()
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() ==  .authorizedAlways {
            self.currentLocation = locManager.location
            completion(true)
        }else{
            completion(false)
        }
    }
    
    func getCurrentAddress(location:CLLocation,hud:JGProgressHUD) {
        let loc: CLLocation = CLLocation(latitude:location.coordinate.latitude, longitude: location.coordinate.longitude)
        let ceo: CLGeocoder = CLGeocoder()
        ceo.reverseGeocodeLocation(
            loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    let pm = placemarks! as [CLPlacemark]
                    
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }
                        print(addressString)
                        self.currentAddress = addressString
                        hud.dismiss()
                        self.CameraBottomSheet()
                    }
                })
    }
    
    func getName() -> String {
        let dateFormatter = DateFormatter()
        let dateFormat = "yyyyMMddHHmmss"
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.string(from: Date())
        let name = date.appending(".mp4")
        return name
    }
    
    func getFriendRecordById(friends:[FriendModel]) {
        for friend in friends{
            self.getAllUsersFromFirebase(friendId: friend.id)
        }
    }
}


//MARK:- FIREBASE METHOD"S EXTENSION
extension HomeViewController{
    // First get user lat,lng
    func getLocation(hud:JGProgressHUD)  {
        self.getUserCurrentLocation { (status) in
            if status{
                self.getCurrentAddress(location: self.currentLocation, hud: hud)
            }else{
                hud.dismiss()
                PopupHelper.alertWithOk(title: "Location Not Found", message: "Your location not found please enable your location from settings", controler: self)
            }
        }
    }
    
    // THIS METHOD IS USED FOR UPLOADING IMAGE INTO FIREBASE DATABASE
    func uploadVideo(_ path: URL, _ userID: String,
                     metadataEsc: @escaping (URL, StorageReference)->(),
                     progressEsc: @escaping (Progress)->(),
                     completionEsc: @escaping ()->(),
                     errorEsc: @escaping (Error)->()) {
        
        let localFile: URL = path
        let videoName = getName()
        let nameRef = Storage.storage().reference().child("/Videos").child(videoName)
        //StorageHandler.videosRef.child(userID).child(videoName)
        let matData = StorageMetadata()
        matData.contentType = "video"
        
        let uploadTask = nameRef.putFile(from: localFile, metadata: matData) { metadata, error in
            if error != nil {
                errorEsc(error!)
            } else {
                nameRef.downloadURL { (url,error) in
                    if let uRl = url{
                        metadataEsc(uRl, nameRef)
                    }
                }
            }
        }
        
        _ = uploadTask.observe(.progress, handler: { snapshot in
            if let progressSnap = snapshot.progress {
                progressEsc(progressSnap)
            }
        })
        
        _ = uploadTask.observe(.success, handler: { snapshot in
            if snapshot.status == .success {
                uploadTask.removeAllObservers()
                completionEsc()
            }
        })
    }
    
    //UPDATE IMAGE URL INTO USER TABLE
    func SaveDatatoDB(videoUrl:String){
        guard let user = self.mAuth.currentUser?.uid else {return}
        ref.child("MyVideos").child(user).childByAutoId().setValue([
            "thumbnail":"\(self.thumbnail)",
            "videoLatitude":"\(self.currentLocation.coordinate.latitude)",
            "videoLocation":self.currentAddress,
            "videoLongitude":"\(self.currentLocation.coordinate.longitude)",
            "videoURL":videoUrl,
        ])
        ref.child("Videos").childByAutoId().setValue([
            "thumbnail":"\(self.thumbnail)",
            "uploaderID":user,
            "videoLatitude":"\(self.currentLocation.coordinate.latitude)",
            "videoLocation":self.currentAddress,
            "videoLongitude":"\(self.currentLocation.coordinate.longitude)",
            "videoURL":videoUrl,
        ])
    }
    
    // GET ALL VIDEOS FROM FIREBASE DATABASE
    func getAllVideo() {
        if Connectivity.isConnectedToNetwork(){
            showHUDView(hudIV: .indeterminate, text: .process) { (hud) in
                hud.show(in: self.view, animated: true)
                //self.favoritesArray.removeAll()
                //if let userID = self.mAuth.currentUser?.uid{
                let reference = self.ref.child("Videos").queryLimited(toLast: 5)
                reference.observe(.value) { (snapshot) in
                    if(snapshot.exists()) {
                        print(snapshot)
                        let array:NSArray = snapshot.children.allObjects as NSArray
                        for obj in array {
                            let snapshot:DataSnapshot = obj as! DataSnapshot
                            if var childSnapshot = snapshot.value as? [String : AnyObject]
                            {
                                childSnapshot[Constant.id] = snapshot.key as String as AnyObject
                                let videos = VideosModel(dic: childSnapshot as NSDictionary)
                                if let video = videos{
                                    self.videoArray.append(video)
                                }
                            }
                        }// End For loop
                        hud.dismiss()
                        self.RecentlyAddedCV.reloadData()
                        self.MyAreaCV.reloadData()
                    }else{
                        hud.dismiss()
                    }// End Snapshot if else statement
                }
            }// End Firebase user id
        }else{
            PopupHelper.showAlertControllerWithError(forErrorMessage: "Internet is unavailable please check your connection", forViewController: self)
        }//End Connectity Check Statement
    }// End get favorite method
    
    // GET ALL FRIENDS LIST FROM FIREBASE DATABASE
    func getAllFriendsFromFirebase() {
        if Connectivity.isConnectedToNetwork(){
            showHUDView(hudIV: .indeterminate, text: .process) { (hud) in
                hud.show(in: self.view, animated: true)
                var friends = [FriendModel]()
                if let userID = self.mAuth.currentUser?.uid{
                    self.ref.child("Friends").child(userID).observeSingleEvent(of: .value) { (snapshot) in
                        if(snapshot.exists()) {
                            let array:NSArray = snapshot.children.allObjects as NSArray
                            for obj in array {
                                let snapshot:DataSnapshot = obj as! DataSnapshot
                                if var childSnapshot = snapshot.value as? [String : AnyObject]{
                                    childSnapshot[Constant.id] = snapshot.key as String as AnyObject
                                    let favData = FriendModel(dic: childSnapshot as NSDictionary)
                                    if let fav = favData{
                                        friends.append(fav)
                                    }
                                }
                            }// End For loop
                            /// - TAG: Filter User DATA
                            self.getFriendRecordById(friends: friends)
                            hud.dismiss()
                        }// End Snapshot if else statement
                        hud.dismiss()
                    }// End ref Child Completion Block
                }// End Firebase user id
                else{
                    hud.dismiss()
                }
            }
        }else{
            PopupHelper.showAlertControllerWithError(forErrorMessage: "Internet is unavailable please check your connection", forViewController: self)
        }//End Connectity Check Statement
    }// End get favorite method
    
    // GET ALL FRIENDS LIST FROM FIREBASE DATABASE
    func getAllUsersFromFirebase(friendId:String) {
        if Connectivity.isConnectedToNetwork(){
            showHUDView(hudIV: .indeterminate, text: .process) { (hud) in
                hud.show(in: self.view, animated: true)
                var friends = [FriendModel]()
                self.ref.child("Friends").child(friendId).observeSingleEvent(of: .value) { (snapshot) in
                    if(snapshot.exists()) {
                        let array:NSArray = snapshot.children.allObjects as NSArray
                        for obj in array {
                            let snapshot:DataSnapshot = obj as! DataSnapshot
                            if var childSnapshot = snapshot.value as? [String : AnyObject]{
                                childSnapshot[Constant.id] = snapshot.key as String as AnyObject
                                let favData = FriendModel(dic: childSnapshot as NSDictionary)
                                if let fav = favData{
                                    friends.append(fav)
                                }
                            }
                        }// End For loop
                        /// - TAG: Send Notification to friend
                        
                        hud.dismiss()
                    }// End Snapshot if else statement
                    hud.dismiss()
                }// End ref Child Completion Block
            }
        }else{
            PopupHelper.showAlertControllerWithError(forErrorMessage: "Internet is unavailable please check your connection", forViewController: self)
        }//End Connectity Check Statement
    }// End get favorite method
    
    
}


//MARK:- UICOLLECTION VIEW DELEGATES AND DATASOURCE METHOD"S EXTENSION
extension HomeViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0{
            return self.videoArray.count
        }else{
            return self.videoArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideosCell", for: indexPath) as! HomeCollectionViewCell
        if collectionView.tag == 0{
            cell.PlayButton.addTarget(self, action: #selector(PlayVideoBtnAction(_:)), for: .touchUpInside)
            cell.PlayButton.tag = indexPath.row
            
            if let data = Data(base64Encoded: self.videoArray[indexPath.row].thumbnail){
                cell.VideoThumbnail.image = UIImage(data: data)
            }
            cell.VideoDate.text = " "
        }else{
            cell.PlayButton.addTarget(self, action: #selector(PlayVideoBtnAction(_:)), for: .touchUpInside)
            cell.PlayButton.tag = indexPath.row
            
            if let data = Data(base64Encoded: self.videoArray[indexPath.row].thumbnail){
                cell.VideoThumbnail.image = UIImage(data: data)
            }
            cell.VideoDate.text = " "
        }
        
        return cell
    }
    
    @objc func PlayVideoBtnAction(_ sender:UIButton){
        let friendListVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "PlayerVC") as! PlayerViewController
        self.navigationController?.pushViewController(friendListVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfItemsPerRow:CGFloat = 1
        let spacingBetweenCellsIphone:CGFloat = 10
        let spacingBetweenCellsIpad:CGFloat = 20
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            let totalSpacing = (2 * self.spacingIphone) + ((numberOfItemsPerRow - 1) * spacingBetweenCellsIphone) //Amount of total spacing in a row
            
            if let collection = self.RecentlyAddedCV{
                let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
                return CGSize(width: width , height: (width/4)*3)
            }else{
                return CGSize(width: 0, height: 0)
            }
        }
        else{
            let totalSpacing = (2 * self.spacingIpad) + ((numberOfItemsPerRow - 1) * spacingBetweenCellsIpad) //Amount of total spacing in a row
            
            if let collection = self.RecentlyAddedCV{
                let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
                return CGSize(width: width , height: width + spacingBetweenCellsIpad * 2)
            }else{
                return CGSize(width: 0, height: 0)
            }
        }
    }
}

//MARK:- CAMERA METHIO'S EXTENSION
extension HomeViewController {
    //BOTTOM SHEET WHICH WILL SHOW TWO OPTION [CAMERA AND GALLERY]
    func CameraBottomSheet() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.Selected_choise(choise: "Camera")
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.Selected_choise(choise: "gallery")
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    // THIS METHOD IS USE FOR CHOICE WHICH IS SELECTED BY USER
    func Selected_choise(choise:String){
        if choise == "gallery"{
            self.openGallery()
        }else{
            self.openCamera()
        }
        self.present(image, animated: true)
    }
    //THIS METHODS WILL OPEN GALLERY FOR IMAGE SELECTION
    func openGallery() {
        image.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.mediaTypes = ["public.movie"]
    }
    // THIS METHOD WILL OPEN CAMERA FOR CAPTURING IMAGE
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            // imagePicker.showsCameraControls = true
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }else {
            PopupHelper.showAlertControllerWithError(forErrorMessage: "Your device not supporting camera", forViewController: self)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let movie = info[.mediaURL] as? URL {
            let file = MediaFile()
            file.videoUrl = movie
            UrlHelper().getThumbnailImageFromVideoUrl(mediaFile: file) { (media) in
                if let image = media.image{
                    if let thumbnail = image.jpegData(compressionQuality: 0.4){
                        self.thumbnail = thumbnail.base64EncodedString()
                        self.uploadVideo(movie, "") { (url, storageRef) in
                            self.SaveDatatoDB(videoUrl: url.absoluteString)
                        } progressEsc: { (progress) in
                            print(progress)
                        } completionEsc: {
                            PopupHelper.alertWithOk(title: "Video Uploaded Successfully", message: "Your video is uploaded successfully", controler: self)
                            //Send notification to friends
                            
                        } errorEsc: { (error) in
                            print(error.localizedDescription)
                        }
                    }else{
                        PopupHelper.showAlertControllerWithError(forErrorMessage: "Video thumbnail generating fail please try again", forViewController: self)
                    }
                }else{
                    PopupHelper.showAlertControllerWithError(forErrorMessage: "Unknown error occur please try again", forViewController: self)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

