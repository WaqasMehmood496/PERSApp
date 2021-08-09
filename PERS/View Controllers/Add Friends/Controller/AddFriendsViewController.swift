//
//  AddFriendsViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 10/06/2021.
//

import UIKit
import Firebase
import SDWebImage
import JGProgressHUD

class AddFriendsViewController: UIViewController {
    
    //MARK: IBOUTLET'S
    @IBOutlet weak var FriendListTableView: UITableView!
    
    //MARK: VARIABLE'S
    var mAuth = Auth.auth()
    var ref: DatabaseReference!
    var allUser = [LoginModel]()
    var friendList = [LoginModel]()
    var friendRequest = [FriendRequestModel]()
    var mySendedRequests = [AllRequestModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        getAllRequests()
    }
}

//MARK:- HELPING METHOD'S EXTENSION
extension AddFriendsViewController{
    //ACCEPT ALL RECORD WHO NOT EQUAL TO FREIEND LIST
    func deleteAlreadyFriends(hud:JGProgressHUD) {
        
        var usersArray = [LoginModel]()
        if friendList.count != 0 {
            for user in self.allUser {
               let result = self.friendList.contains(where: { (LoginModel) -> Bool in
                    if LoginModel.id == user.id {
                        return true
                    } else {
                        return false
                    }
                })
                if result == false{
                    usersArray.append(user)
                }
            }
            self.allUser = usersArray
            usersArray.removeAll()
        }
        
        if friendRequest.count != 0 {
            for user in self.allUser {
                let result = self.friendRequest.contains(where: { (request) -> Bool in
                     if request.id == user.id {
                         return true
                     } else {
                         return false
                     }
                 })
                 if result == false{
                     usersArray.append(user)
                 }
            }
            self.allUser = usersArray
            usersArray.removeAll()
        }
        
        if let myId = CommonHelper.getCachedUserData()?.id {
            for user in self.allUser{
                if user.id != myId{
                    usersArray.append(user)
                }
            }
            self.allUser = usersArray
            usersArray.removeAll()
        }
        hud.dismiss()
        self.FriendListTableView.reloadData()
    }
    
}

//MARK:- FIREBASE METHOD'S EXTENSION
extension AddFriendsViewController{
    
    func getAllRequests() {
        if Connectivity.isConnectedToNetwork(){
            showHUDView(hudIV: .indeterminate, text: .process) { (hud) in
                hud.show(in: self.view, animated: true)
                if (self.mAuth.currentUser?.uid) != nil {
                    self.ref.child("Requests").observeSingleEvent(of: .value) { (snapshot) in
                        if(snapshot.exists()) {
                            let array:NSArray = snapshot.children.allObjects as NSArray
                            for obj in array {
                                let snapshot:DataSnapshot = obj as! DataSnapshot
                                let request = AllRequestModel(dic: snapshot)
                                if let user = request{
                                    self.mySendedRequests.append(user)
                                }
                                
                            }// End For loop
                        }// End Snapshot if else statement
                        self.deleteAlreadyFriends(hud: hud)
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
    
    
    func addIntoMyFriendRequest(friendId:String,index:Int){
        guard let user = mAuth.currentUser?.uid else {
            return
        }
        if let currentUser = CommonHelper.getCachedUserData(){
            ref.child("Requests").child(friendId).child(user).setValue([
                "imageURL":currentUser.imageURL,
                "name":currentUser.name
            ])
        }
        self.allUser.remove(at: index)
        self.FriendListTableView.reloadData()
    }// End Add in to favorites method
}

// MARK:- UITBLEVIEW DATASOURCE AND DELEGATES EXTENSION
extension AddFriendsViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListCell", for: indexPath) as! NotificationTableViewCell
        cell.AddFriendBtn.addTarget(self, action: #selector(AddFriendBtnAction(_:)), for: .touchUpInside)
        cell.AddFriendBtn.tag = indexPath.row
        cell.Title.text = self.allUser[indexPath.row].name
        cell.Description.text = self.allUser[indexPath.row].location
        if let image = self.allUser[indexPath.row].imageURL{
            cell.UserImage.sd_setImage(with: URL(string: image), placeholderImage: #imageLiteral(resourceName: "Logo"))
        }
        let bgColorView = UIView()
        bgColorView.backgroundColor = .clear
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    @objc func AddFriendBtnAction(_ sender:UIButton){
        /// - TAG:  Send friend request
        self.addIntoMyFriendRequest(friendId: self.allUser[sender.tag].id, index: sender.tag)
    }
}
