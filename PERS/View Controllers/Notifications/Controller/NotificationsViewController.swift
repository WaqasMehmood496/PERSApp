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
        self.navigationController?.navigationBar.isHidden = false
        if let notifiArray = CommonHelper.getNotificationCachedData() {
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
        let selected = self.notificationsArray[indexPath.row]
        let video = [VideosModel(id: selected.uploaderid, thumbnail: selected.thumbnail, uploaderID: selected.uploaderid, videoLatitude: selected.videoLatitude, videoLocation: selected.videoLocation, videoLongitude: selected.videoLongitude, videoURL: selected.videoURL, timestamp: selected.timestamp, userName: selected.detail, userImage: selected.userimage)]
        
        
        let playViewController = UIStoryboard.init (
            name: Constant.mainStotyboard,
            bundle: Bundle.main
        ).instantiateViewController (
            identifier: playVCIdentifier
        ) as! PlayerViewController
        playViewController.MyAreaVideos = video
        playViewController.SelectedVideo = video.first!
        playViewController.isShowMoreVideos = false
        self.navigationController?.pushViewController ( playViewController, animated: true )
    }
}
