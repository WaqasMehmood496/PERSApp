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
    //VARIABLES
    var notificationsArray = [NotificationModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let notifiArray = CommonHelper.getNotificationCachedData(){
            notificationsArray = notifiArray
        }
        self.NotificationTableView.reloadData()
    }
}

//MARK:- UITABLEVIEW DELEGATE'S AND METHOD'S
extension NotificationsViewController:UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
        cell.Title.text = self.notificationsArray[indexPath.row].title
        cell.Description.text = self.notificationsArray[indexPath.row].detail
        return cell
    }
}
