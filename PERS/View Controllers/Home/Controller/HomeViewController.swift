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
import FirebaseStorage
import FirebaseMessaging

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
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
    var myLocation = CLLocationCoordinate2D()
    var currentAddress = String()
    let image = UIImagePickerController()
    var thumbnail = String()
    var videoArray = [VideosModel]()
    var MyAreaVideos = [VideosModel]()
    let notificationSender = PushNotificationSender()
    var isAllVideosSelected = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.collectionViewSetup()
        self.updateToken()
        self.getCurrentLocation()
        self.getAllVideo()
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
    
    //UPDATE USER TOKEN
    func updateToken() {
        guard let user = self.mAuth.currentUser?.uid else {return}
        if let token = Messaging.messaging().fcmToken{
            ref.child("Users").child(user).child("token").setValue(token)
        }
    }
    
    // First get user lat,lng
    func getLocation(hud:JGProgressHUD)  {
        self.getUserCurrentLocation { (status) in
            if status{
                self.getCurrentAddress(location: self.currentLocation, hud: hud)
            }else{
                hud.dismiss()
                PopupHelper.alertWithOk(title: "Location Not Found", message: "Your location not found please enable your location from settings", controler: self)
                locManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    //GET USER CURRENT LOCATION
    func getUserCurrentLocation(completion: (Bool) -> ()) {
        locManager.requestWhenInUseAuthorization()
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() ==  .authorizedAlways {
            self.currentLocation = locManager.location
            //Get all videos from favorites
            self.getAllVideo()
            
            completion(true)
        }else{
            completion(false)
        }
    }
    
    // This method will fetch user current location address using lat lng
    func getCurrentAddress(location:CLLocation,hud:JGProgressHUD) {
        let loc: CLLocation = CLLocation(latitude:location.coordinate.latitude, longitude: location.coordinate.longitude)
        let ceo: CLGeocoder = CLGeocoder()
        ceo.reverseGeocodeLocation(
            loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil){
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
    
    // This method will create new name for recorded video by using datetime and extension .mp3
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
            self.getFriendByIdFromUsersRecord(friendId: friend.id)
        }
    }
    
    // This methods will get user current location
    func getCurrentLocation() {
        locManager.requestWhenInUseAuthorization()
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() ==  .authorizedAlways {
            self.currentLocation = locManager.location
            self.getAllVideosInMyArea()
        }else{
            PopupHelper.alertWithOk(title: "Location not found", message: "Your location access is private please give the access to search videos around your", controler: self)
        }
        
    }
    
    // This methods will filter nearest videos using lat lng distance
    func checkMyNearestVideos(videos: [VideosModel]) {
        var tempArray = [VideosModel]()
        for video in videos{
            if let videoLat = CLLocationDegrees(video.videoLatitude) , let videoLng = CLLocationDegrees(video.videoLongitude){
                let videoLocation = CLLocation(latitude: videoLat, longitude: videoLng)
                let distance = self.currentLocation.distance(from: videoLocation) / 1000
                if(distance <= 3218)
                {
                    tempArray.append(video)
                }
            }
        }//End For loop
        let hud = JGProgressHUD()
        hud.dismiss()
        self.getUsersAccordingVideos(hud: hud, videos: tempArray, isRecent: false)
        
    }
    
    //This method will change time stamp into date time and return only time
    func getTimeFromTimeStamp(timeStamp:Double) -> String{
        let date = NSDate(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        let localDate = dateFormatter.string(from: date as Date)
        if let getTime = localDate.components(separatedBy: "at").last{
            return getTime
        }
        return " "
    }
}


//MARK:- FIREBASE METHOD"S EXTENSION
extension HomeViewController{

    // THIS METHOD IS USED FOR UPLOADING IMAGE INTO FIREBASE DATABASE
    func uploadVideo(_ path: URL, _ userID: String,
                     metadataEsc: @escaping (URL, StorageReference)->(),
                     progressEsc: @escaping (Progress)->(),
                     completionEsc: @escaping ()->(),
                     errorEsc: @escaping (Error)->()) {
        
        let localFile: URL = path
        let videoName = getName()
        let nameRef = Storage.storage().reference().child("/Videos").child(videoName)
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
        let timestamp = NSDate().timeIntervalSince1970
        ref.child("MyVideos").child(user).childByAutoId().setValue([
            "thumbnail":"\(self.thumbnail)",
            "timestamp":"\(timestamp)",
            "videoLatitude":"\(self.currentLocation.coordinate.latitude)",
            "videoLocation":self.currentAddress,
            "videoLongitude":"\(self.currentLocation.coordinate.longitude)",
            "videoURL":videoUrl,
        ])
        ref.child("Videos").childByAutoId().setValue([
            "thumbnail":"\(self.thumbnail)",
            "timestamp":"\(timestamp)",
            "uploaderID":user,
            "videoLatitude":"\(self.currentLocation.coordinate.latitude)",
            "videoLocation":self.currentAddress,
            "videoLongitude":"\(self.currentLocation.coordinate.longitude)",
            "videoURL":videoUrl,
        ])
        //Get all friends List
        self.getAllFriendsFromFirebase()
    }
    
    // GET ALL VIDEOS FROM FIREBASE DATABASE
    func getAllVideo() {
        if Connectivity.isConnectedToNetwork(){
            showHUDView(hudIV: .indeterminate, text: .process) { (hud) in
                hud.show(in: self.view, animated: true)
                let reference = self.ref.child("Videos").queryLimited(toLast: 5)
                reference.observe(.value) { (snapshot) in
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
                        self.getUsersAccordingVideos(hud: hud, videos: tempArray, isRecent: true)
                    }else{
                        hud.dismiss()
                    }// End Snapshot if else statement
                }
            }// End Firebase user id
        }else{
            PopupHelper.showAlertControllerWithError(forErrorMessage: "Internet is unavailable please check your connection", forViewController: self)
        }//End Connectity Check Statement
    }// End get favorite method
    
    // GET ALL VIDEOS FROM FIREBASE DATABASE
    func getUsersAccordingVideos(hud:JGProgressHUD,videos:[VideosModel],isRecent:Bool) {
        if Connectivity.isConnectedToNetwork(){
            self.ref.child("Users").observe(.value) { (snapshot) in
                if(snapshot.exists()) {
                    let array:NSArray = snapshot.children.allObjects as NSArray

                    for obj in array {
                        let snapshot:DataSnapshot = obj as! DataSnapshot
                        if var childSnapshot = snapshot.value as? [String : AnyObject]{
                            childSnapshot[Constant.id] = snapshot.key as String as AnyObject
                            let users = LoginModel(dic: childSnapshot as NSDictionary)
                            if let user = users{
                                for video in videos{
                                    if video.uploaderID == user.id{
                                        video.videoUploaderImageUrl = user.imageURL
                                        video.videoUploaderName = user.name
                                        if isRecent == true{
                                            self.videoArray.append(video)
                                        }else{
                                            self.MyAreaVideos.append(video)
                                        }
                                    }
                                }
                            }
                        }
                    }// End For loop
                    
                    hud.dismiss()
                    self.RecentlyAddedCV.reloadData()
                    self.MyAreaCV.reloadData()
                }else{
                    hud.dismiss()
                }// End Snapshot if else statement
            }// End Firebase user id
        }else{
            PopupHelper.showAlertControllerWithError(forErrorMessage: "Internet is unavailable please check your connection", forViewController: self)
        }//End Connectity Check Statement
    }// End get favorite method
    
    
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
    
    
    
    // GET ALL FRIENDS LIST FROM FIREBASE DATABASE
    func getAllFriendsFromFirebase() {
        if Connectivity.isConnectedToNetwork(){
            var friends = [FriendModel]()
            self.ref.child("Friends").observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
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
                }// End Snapshot if else statement
            }// End ref Child Completion Block
        }else{
            PopupHelper.showAlertControllerWithError(forErrorMessage: "Internet is unavailable please check your connection", forViewController: self)
        }//End Connectity Check Statement
    }// End get favorite method
    
    // GET ALL FRIENDS TOKEN FROM USER AND SEND PUSH NOTIFICATION
    func getFriendByIdFromUsersRecord(friendId:String) {
        if Connectivity.isConnectedToNetwork(){
            self.ref.child("Users").child(friendId).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                //let key = snapshot.key as? NSDictionary
                let user = LoginModel(dic: value as! NSDictionary)
                if let userData = user{
                    if userData.token != nil || userData.token != ""{
                        if let userName = user?.name{
                            self.notificationSender.sendPushNotification(to: userData.token, title: "\(userName)", body: "New video uploaded")
                        }
                    }
                }
                PopupHelper.changeRootView(storyboardName: "Main", ViewControllerId: "Tabbar")
            }){
                (error) in
                print(error.localizedDescription)
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
            return self.MyAreaVideos.count
        }else{
            return self.videoArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideosCell", for: indexPath) as! HomeCollectionViewCell
        if collectionView.tag == 0{
            self.isAllVideosSelected = true
            cell.PlayButton.addTarget(self, action: #selector(PlayVideoBtnAction(_:)), for: .touchUpInside)
            cell.PlayButton.tag = indexPath.row
            if let timeStm = self.MyAreaVideos[indexPath.row].timestamp{
                if let timeStamp = Double(timeStm){
                    cell.VideoDate.text = self.getTimeFromTimeStamp(timeStamp: timeStamp)
                }
            }
            cell.PersonImage.sd_setImage(with: URL(string: self.MyAreaVideos[indexPath.row].videoUploaderImageUrl), placeholderImage: #imageLiteral(resourceName: "Clip-2"))
            cell.PersonName.text = self.MyAreaVideos[indexPath.row].videoUploaderName
            if let data = Data(base64Encoded: self.MyAreaVideos[indexPath.row].thumbnail){
                cell.VideoThumbnail.image = UIImage(data: data)
            }
        }else{
            self.isAllVideosSelected = false
            cell.PlayButton.addTarget(self, action: #selector(PlayVideoBtnAction(_:)), for: .touchUpInside)
            cell.PlayButton.tag = indexPath.row            
            if let timeStm = self.videoArray[indexPath.row].timestamp{
                if let timeStamp = Double(timeStm){
                    cell.VideoDate.text = self.getTimeFromTimeStamp(timeStamp: timeStamp)
                }
            }
            cell.PersonImage.sd_setImage(with: URL(string: self.videoArray[indexPath.row].videoUploaderImageUrl), placeholderImage: #imageLiteral(resourceName: "Clip-2"))
            cell.PersonName.text = self.videoArray[indexPath.row].videoUploaderName
            if let data = Data(base64Encoded: self.videoArray[indexPath.row].thumbnail){
                cell.VideoThumbnail.image = UIImage(data: data)
            }
        }
        
        return cell
    }
    
    @objc func PlayVideoBtnAction(_ sender:UIButton){
        let playViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "PlayerVC") as! PlayerViewController
        if isAllVideosSelected{
            playViewController.MyAreaVideos = self.MyAreaVideos
        }else{
            playViewController.MyAreaVideos = self.videoArray
        }
        self.navigationController?.pushViewController(playViewController, animated: true)
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
                            //PopupHelper.alertWithOk(title: "Video Uploaded Successfully", message: "Your video is uploaded successfully", controler: self)
                            
                        } errorEsc: { (error) in
                            PopupHelper.alertWithOk(title: "Video Uploaded Fail", message: "\(error.localizedDescription)", controler: self)
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
