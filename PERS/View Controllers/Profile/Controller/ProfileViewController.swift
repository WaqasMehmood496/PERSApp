//
//  ProfileViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 10/06/2021.
//

import UIKit
import SDWebImage
import Firebase
import JGProgressHUD

class ProfileViewController: UIViewController, FriendRequestsDelegate {
    
    //MARK: IBOUTLET'S
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var UserEmailLabel: UILabel!
    @IBOutlet weak var FullNameLabel: UILabel!
    @IBOutlet weak var EmailAddressLabel: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var FriendListTableView: UITableView!
    @IBOutlet weak var FriendRequestLabel: UILabel!
    @IBOutlet weak var TotalFriendCountLabel: UILabel!
    @IBOutlet weak var FriendRequestBtn: UIButton!
    
    //MARK: VARIABLE'S
    var mAuth = Auth.auth()
    var ref: DatabaseReference!
    var friendList = [LoginModel]()
    var allUser = [LoginModel]()
    var isImageUpdate = false
    var friendsRequests = [FriendRequestModel]()
    let image = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.setupUI()
        self.getAllUsersRecord()
        self.getFriendsFromFirebase()
    }
    
    @IBAction func AddFriendsBtnAction(_ sender: Any) {
        let friendListVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "AddFriendVC") as! AddFriendsViewController
        friendListVC.allUser = self.allUser
        friendListVC.friendList = self.friendList
        friendListVC.friendRequest = self.friendsRequests
        self.navigationController?.pushViewController(friendListVC, animated: true)
    }
    
    @IBAction func SignoutBtnAction(_ sender: Any) {
        //Remove user data from cache
        CommonHelper.removeCachedUserData()
        //Change root view
        PopupHelper.changeRootViewController(storyboardName: "Main", ViewControllerId: "LoginVC")
    }
    
    @IBAction func UpdateProfileImageBtnAction(_ sender: Any) {
        if isImageUpdate{
            if let image = self.ProfileImage.image{
                self.uploadImage(image)
            }
        }else{
            PopupHelper.alertWithOk(title: "Image Not Selected", message: "Please capture image from camera or select from gallery to update image", controler: self)
        }
    }
    @IBAction func CaptureImageBtnAction(_ sender: Any) {
        self.CameraBottomSheet()
    }
    @IBAction func FriendRequestBtnAction(_ sender: Any) {
        self.performSegue(withIdentifier: "toFriendRequests", sender: nil)
    }
}

//MARK:- HELPING METHO'D EXTENSION
extension ProfileViewController {
    // SETUP USER INTERFACE WITH SOME MODIFICATION
    func setupUI() {
        if let userData = CommonHelper.getCachedUserData(){
            UserNameLabel.text = userData.name
            UserEmailLabel.text = userData.email
            FullNameLabel.text = userData.name
            EmailAddressLabel.text = userData.email
            LocationLabel.text = userData.location
            PasswordLabel.text = userData.password
            self.ProfileImage.sd_setImage(with: URL(string: userData.imageURL), placeholderImage: #imageLiteral(resourceName: "Clip"))
        }
    }
    //THIS METHOD WILL COMPARE THE FRIEND ID TO ALL USER RECORDS TO FETCH WHICH USER IS IN FRIEND LIST
    func compareRecord(friendArray:[FriendModel]) {
        self.friendList.removeAll()
        for friend in friendArray{
            for user in self.allUser{
                if user.id == friend.id{
                    self.friendList.append(user)
                }
            }//End friend loop
        }//End user loop
        self.FriendListTableView.reloadData()
    }
    
    func updateUI(hud:JGProgressHUD) {
        self.FriendRequestLabel.text = "You have \(self.friendsRequests.count) friends requests"
        self.FriendRequestBtn.setTitle("\(self.friendsRequests.count)", for: .normal)
        hud.dismiss()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFriendRequests" {
            if let friendRequestVC = segue.destination as? FriendRequestViewController {
                friendRequestVC.allRequests = self.friendsRequests
                friendRequestVC.delegate = self
            }
        }
    }
    //THIS DELEGATE METHOD WILL UPDATE THE FRIEND REQUEST ARRAY AND FRIEND LIST
    func updateFriendRequestData(data: [FriendRequestModel]) {
        self.friendsRequests = data
        self.FriendRequestLabel.text = "\(data.count)"
        //self.getFriendsFromFirebase()//Fetch all friends
    }
}



//MARK:- FIREBASE METHOD'S EXTENSION
extension ProfileViewController{
    //GET ALL USERS RECORD FROM FIREBASE DATABASE
    func getAllUsersRecord() {
        if Connectivity.isConnectedToNetwork() {
            if (self.mAuth.currentUser?.uid) != nil {
                self.ref.child("Users").observeSingleEvent(of: .value) { (snapshot) in
                    if(snapshot.exists()) {
                        let array:NSArray = snapshot.children.allObjects as NSArray
                        for obj in array {
                            let snapshot:DataSnapshot = obj as! DataSnapshot
                            if var childSnapshot = snapshot.value as? [String : AnyObject] {
                                childSnapshot[Constant.id] = snapshot.key as String as AnyObject
                                let users = LoginModel(dic: childSnapshot as NSDictionary)
                                if let user = users {
                                    self.allUser.append(user)
                                }
                                print(childSnapshot)
                            }
                        }// End For loop
                    }// End Snapshot if else statement
                }// End ref Child Completion Block
            }// End Firebase user id
            else{
            }
        }else{
            PopupHelper.showAlertControllerWithError( forErrorMessage: "Internet is unavailable please check your connection", forViewController: self )
        }//End Connectity Check Statement
    }// End get favorite method
    
    // GET ALL FRIENDS VIDEOS FROM FIREBASE DATABASE
    func getFriendsFromFirebase() {
        if Connectivity.isConnectedToNetwork() {
            showHUDView(hudIV: .indeterminate, text: .process) { (hud) in
                hud.show(in: self.view, animated: true)
                var friends = [FriendModel]()
                if let userID = self.mAuth.currentUser?.uid {
                    self.ref.child("Friends").child(userID).observe(.value) { (snapshot) in
                        if(snapshot.exists()) {
                            self.friendList.removeAll()
                            let array:NSArray = snapshot.children.allObjects as NSArray
                            for obj in array {
                                let snapshot:DataSnapshot = obj as! DataSnapshot
                                if var childSnapshot = snapshot.value as? [String : AnyObject] {
                                    childSnapshot[Constant.id] = snapshot.key as String as AnyObject
                                    let favData = FriendModel(dic: childSnapshot as NSDictionary)
                                    if let fav = favData{
                                        friends.append(fav)
                                    }
                                }
                            }// End For loop
                            hud.dismiss()
                        }// End Snapshot if else statement
                        self.compareRecord(friendArray: friends)
                        self.TotalFriendCountLabel.text = "You have \(friends.count) friends"
                        self.getFriendRequestsFromFirebase(hud: hud)
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
    
    //THIS METHODS WILL FETCH ALL FRIENDS REQUESTS
    func getFriendRequestsFromFirebase(hud:JGProgressHUD) {
        if Connectivity.isConnectedToNetwork(){
            if let userID = self.mAuth.currentUser?.uid{
                self.ref.child("Requests").child(userID).observeSingleEvent(of: .value) { (snapshot) in
                    if (snapshot.exists()) {
                        let array:NSArray = snapshot.children.allObjects as NSArray
                        for obj in array {
                            let snapshot:DataSnapshot = obj as! DataSnapshot
                            if let frindRequest = FriendRequestModel(dic: snapshot) {
                                self.friendsRequests.append(frindRequest)
                            }
                        }// End For loop
                        self.updateUI(hud: hud)
                    }else{
                        hud.dismiss()
                    }// End Snapshot if else statement
                }// End ref Child Completion Block
            }// End Firebase user id
            else{
                hud.dismiss()
            }
        }else{
            PopupHelper.showAlertControllerWithError(forErrorMessage: "Internet is unavailable please check your connection", forViewController: self)
        }//End Connectity Check Statement
    }// End get favorite method
    
    
    // THIS METHOD IS USED FOR UPLOADING IMAGE INTO FIREBASE DATABASE
    func uploadImage(_ image: UIImage){
        if Connectivity.isConnectedToNetwork(){
            showHUDView(hudIV: .indeterminate, text: .process) { (hud) in
                hud.show(in: self.view, animated: true)
                let imageName = UUID().uuidString
                let storageRef = Storage.storage().reference().child("/Profile_Images").child(imageName)
                if let uploadData = image.jpegData(compressionQuality: 0.5){
                    let metaDataForImage = StorageMetadata()
                    metaDataForImage.contentType = "image/jpeg"
                    storageRef.putData(
                        uploadData, metadata: metaDataForImage
                        , completion: { (metadata, error) in
                            if error != nil {
                                print("error")
                                PopupHelper.showAlertControllerWithError(forErrorMessage: "Storage reference not found", forViewController: self)
                                hud.dismiss()
                                return
                            }
                            else{
                                storageRef.downloadURL(completion: { (url, error) in
                                    if error != nil {
                                        PopupHelper.showAlertControllerWithError(forErrorMessage: "Uploading file error", forViewController: self)
                                        hud.dismiss()
                                    }
                                    else{
                                        if let urlText = url?.absoluteString {
                                            self.SaveDatatoDB(imageurl: urlText, hud: hud)
                                        }else{
                                            hud.dismiss()
                                        }
                                    }//End checking error statement
                                })//End downloadURL completion
                            }//End checking error statement
                        })//End storage Ref
                }else{
                    PopupHelper.showAlertControllerWithError(forErrorMessage: "Image compression failed", forViewController: self)
                    hud.dismiss()
                }//End uploadData Statement
            }//End Hud Statement
        }else{
            PopupHelper.showAlertControllerWithError(forErrorMessage: "Internet is unavailable please check your connection", forViewController: self)
        }//End internet connection statement
    }//End Uploading function
    
    //UPDATE IMAGE URL INTO USER TABLE
    func SaveDatatoDB(imageurl:String,hud:JGProgressHUD){
        guard let user = self.mAuth.currentUser?.uid else {return}
        ref.child("Users").child(user).updateChildValues(["imageURL" : imageurl], withCompletionBlock: { (error, ref) in
            if error != nil{
                hud.dismiss()
                return
            }
            else{
                hud.dismiss()
            }
        })
        
        //UPDATE DATA INTO CACHE
        if let userData = CommonHelper.getCachedUserData(){
            userData.imageURL = imageurl
            CommonHelper.saveCachedUserData(userData)
        }
    }
}

// MARK:- UITBLEVIEW DATASOURCE AND DELEGATES EXTENSION
extension ProfileViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListCell", for: indexPath) as! NotificationTableViewCell
        cell.Title.text = self.friendList[indexPath.row].name
        cell.Description.text = self.friendList[indexPath.row].location
        cell.UserImage.sd_setImage(with: URL(string: self.friendList[indexPath.row].imageURL), placeholderImage: #imageLiteral(resourceName: "Logo"))
        let bgColorView = UIView()
        bgColorView.backgroundColor = .clear
        cell.selectedBackgroundView = bgColorView
        return cell
    }
}

//MARK:- CAMERA METHIO'S EXTENSION
extension ProfileViewController {
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
        image.allowsEditing = false
        self.present(image, animated: true)
    }
    //THIS METHODS WILL OPEN GALLERY FOR IMAGE SELECTION
    func openGallery() {
        image.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.mediaTypes = ["public.image", "public.movie"]
    }
    // THIS METHOD WILL OPEN CAMERA FOR CAPTURING IMAGE
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }else {
            PopupHelper.showAlertControllerWithError(forErrorMessage: "Your device not supporting camera", forViewController: self)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            self.ProfileImage.image = editedImage
            //self.uploadImage(editedImage)
            isImageUpdate = true
        } else if let originalImage = info[.originalImage] as? UIImage {
            self.ProfileImage.image = originalImage
            //self.uploadImage(originalImage)
            isImageUpdate = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
