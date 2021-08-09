//
//  FriendRequestViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 18/06/2021.
//

import UIKit
import Firebase

class FriendRequestViewController: UIViewController {
    
    //MARK:IBOUTLET'S
    @IBOutlet weak var FriendRequests: UITableView!
    
    //MARK: VARIABLE'S
    var allRequests = [FriendRequestModel]()
    var mAuth = Auth.auth()
    var delegate:FriendRequestsDelegate?
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
}

//MARK:- FIREBASE METHOD'S EXTENDSION
extension FriendRequestViewController{
    // THIS METHOD WILL SAVE OR ADD NEW RECORD IN FIREBASE FAVORITE DATABASE
    func addIntoMyFriendList(friendId:String){
        guard let user = mAuth.currentUser?.uid else {
            return
        }
        ref.child("Friends").child(user).child(friendId).setValue([
            "friend":true
        ])
    }// End Add in to favorites method
    func addIntoFriendList(friendId:String){
        guard let user = mAuth.currentUser?.uid else {
            return
        }
        self.ref.child("Friends").child(friendId).child(user).setValue([
            "friend":true
        ])
    }// End Add in to favorites method
    
    func RemoveRequestFromFriendRequest(friendId:String,index:Int){
        guard let user = mAuth.currentUser?.uid else {
            return
        }
        self.ref.child("Requests").child(user).child(friendId).removeValue { (error, _ in) in
            if error == nil{
                self.allRequests.remove(at: index)
                self.FriendRequests.reloadData()
                //Call delegate to pass updated array to profile vc
                self.delegate?.updateFriendRequestData(data: self.allRequests)
            }else{
                PopupHelper.showAlertControllerWithError(forErrorMessage: "Unknown error found, image can not be deleted", forViewController: self)
            }
        }
    }// End Add in to favorites method
}


// MARK:- UITBLEVIEW DATASOURCE AND DELEGATES EXTENSION
extension FriendRequestViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListCell", for: indexPath) as! NotificationTableViewCell
        cell.Description.text = " "
        cell.Title.text = self.allRequests[indexPath.row].name
        if let image = self.allRequests[indexPath.row].imageURL{
            cell.UserImage.sd_setImage(with: URL(string: image), placeholderImage: #imageLiteral(resourceName: "Logo"))
        }
        cell.AddFriendBtn.addTarget(self, action: #selector(AddFriendBtnAction(_:)), for: .touchUpInside)
        cell.AddFriendBtn.tag = indexPath.row
        cell.CancelBtn.addTarget(self, action: #selector(CancelBtnAction(_:)), for: .touchUpInside)
        cell.CancelBtn.tag = indexPath.row
        let bgColorView = UIView()
        bgColorView.backgroundColor = .clear
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    @objc func AddFriendBtnAction(_ sender:UIButton){
        /// - TAG: SAVE INTO OWN RECOED
        self.addIntoMyFriendList(friendId: self.allRequests[sender.tag].id)
        /// - TAG: SAVE INTO REQUESTED USER RECORD
        self.addIntoFriendList(friendId: self.allRequests[sender.tag].id)
        //Delete from requests table
        self.RemoveRequestFromFriendRequest(friendId: self.allRequests[sender.tag].id, index: sender.tag)
        
    }
    
    @objc func CancelBtnAction(_ sender:UIButton){
        self.RemoveRequestFromFriendRequest(friendId: self.allRequests[sender.tag].id, index: sender.tag)
    }
}
