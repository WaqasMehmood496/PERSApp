//
//  NotificationsViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 09/06/2021.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    // IBOUTLET'S
    @IBOutlet weak var NotificationTableView: UITableView!
    
    //CONSTANTS
    let playVCIdentifier = "PlayerVC"
    
    //VARIABLES
    var notificationsArray = [NotificationModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if let notifiArray = CommonHelper.getNotificationCachedData(){
            notificationsArray = notifiArray
        }
        self.NotificationTableView.reloadData()
    }
}

//MARK:- UITABLEVIEW DELEGATE'S AND METHOD'S
extension NotificationsViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
        cell.Title.text = self.notificationsArray[indexPath.row].title
        cell.Description.text = self.notificationsArray[indexPath.row].detail
        let bgColorView = UIView()
        bgColorView.backgroundColor = .clear
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let video = [VideosModel(id: self.notificationsArray[indexPath.row].uploaderID, thumbnail: "", uploaderID: self.notificationsArray[indexPath.row].uploaderID, videoLatitude: self.notificationsArray[indexPath.row].videoLongitude, videoLocation: self.notificationsArray[indexPath.row].videoLocation, videoLongitude: self.notificationsArray[indexPath.row].videoLongitude, videoURL: self.notificationsArray[indexPath.row].videoURL, timestamp: self.notificationsArray[indexPath.row].timestamp, userName: "ABC", userImage: "Clip")]
        
        
        let playViewController = UIStoryboard.init (
            name: Constant.mainStotyboard,
            bundle: Bundle.main
        ).instantiateViewController (
            identifier: playVCIdentifier
        ) as! PlayerViewController
        playViewController.MyAreaVideos = video
        playViewController.SelectedVideo = video.first!
        
        self.navigationController?.pushViewController ( playViewController, animated: true )
    }
}
