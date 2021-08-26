//
//  AppDelegate.swift
//  PERS
//
//  Created by Buzzware Tech on 09/06/2021.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseCore
import FirebaseMessaging
import FirebaseInstallations
import IQKeyboardManagerSwift
import SwiftyJSON
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var deviceTokenForPushN = ""
    
    override init() {
        super .init()
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyBnQngZXCKUwwNfO6i4JiEwQEU8Lb8zSus")
        self.setUpAppNotifications()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        self.checkUserAlreadyLogin()
        
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Messaging.messaging().apnsToken = deviceToken
        print ("ashdgjasjda" , deviceToken )
        print("Device Token: \(token)")
    }
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}


//MARK:- HELPING METHOD'S
extension AppDelegate{
    func checkUserAlreadyLogin() {
        var storyboard :UIStoryboard!
        if UIDevice.current.userInterfaceIdiom == .phone{
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        }
        else{
            storyboard = UIStoryboard(name: "Ipad", bundle: nil)
        }
        if (CommonHelper.getCachedUserData()?.id != nil){
            let controller = storyboard.instantiateViewController(identifier: "Tabbar")
            self.window?.rootViewController = controller
        }else{
            let controller = storyboard.instantiateViewController(identifier: "LoginVC")
            self.window?.rootViewController = controller
        }
        self.window?.makeKeyAndVisible()
    }
}


//MARK:- NOTIFICATION HELPING METHOD'S
extension AppDelegate{
    func setUpAppNotifications() {
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        deviceTokenForPushN = (" \(token ?? "")")
        print("FCM deviceTokenForPushN: \(deviceTokenForPushN )")
        UserDefaults.standard.set(deviceTokenForPushN, forKey: "Constant.token_id")
        UserDefaults.standard.synchronize()
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = self
        self.registerForPushNotifications()
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
            }
    }
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                NotificationCenter.default.addObserver(self, selector: #selector(self.refreshToken(notification:)) , name: .MessagingRegistrationTokenRefreshed, object: nil)
            }
        }
    }
    @objc func refreshToken(notification : NSNotification) {
        Installations.installations().installationID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result)")
            }
        }
    }
    
    func saveIntoCache(videoData:NSDictionary,title:String,detail:String) {
        let notification = NotificationModel()
        notification.detail = detail
        notification.title = title
        if let videoUrl =  videoData["videoURL"] as? String {
            notification.videoURL = videoUrl
        }
        if let thumbnail =  videoData["thumbnail"] as? String {
            notification.thumbnail = thumbnail
        }
        if let timestamp =  videoData["timestamp"] as? String {
            notification.timestamp = timestamp
        }
        if let uploaderid =  videoData["uploaderid"] as? String {
            notification.uploaderid = uploaderid
        }
        if let userimage =  videoData["userimage"] as? String {
            notification.userimage = userimage
        }
        if let videoLatitude =  videoData["videoLatitude"] as? String {
            notification.videoLatitude = videoLatitude
        }
        if let videoLongitude =  videoData["videoLongitude"] as? String {
            notification.videoLongitude = videoLongitude
        }
        if let videoURL =  videoData["v"] as? String {
            notification.videoURL = videoURL
        }
        
        // SAVE INTO NOTIFICATION
        if var notificationCache = CommonHelper.getNotificationCachedData(){
            notificationCache.append(notification)
            CommonHelper.saveNotificationCachedData(notificationCache)
        }
        else {
            var array = [NotificationModel]()
            array.append(notification)
            CommonHelper.saveNotificationCachedData(array)
        }
        
    }
}

//MARK:- NOTIFICATION DELEGATES METHOD'S
extension AppDelegate:UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.identifier == "Local Notification Order" {
            print("Handling notifications with the Local Notification Identifier")
            center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
            center.removePendingNotificationRequests(withIdentifiers: [notification.request.identifier])
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler(UNNotificationPresentationOptions([.badge,.banner,.sound]))
        let userInfo = notification.request.content.userInfo
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(UNNotificationPresentationOptions([.badge,.banner,.sound]))
            return
        }
        print(userInfo as NSDictionary)
        print(aps)
        
        if let videoData = userInfo as? NSDictionary {
            if let alert = aps["alert"] as? [String:AnyObject] {
                guard let title = alert["title"] as? String else {
                    return
                }
                guard let detail = alert["body"] as? String else {
                    return
                }
                self.saveIntoCache(videoData: videoData, title: title, detail: detail)
            }
            
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "Local Notification Order" {
            print("Handling notifications with the Local Notification Identifier")
            center.removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
            UIApplication.shared.applicationIconBadgeNumber = 0
            completionHandler()
            
        }
    }
    
    @objc func userNotify(){
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
                return
            }
        }
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
                return
            }
        }
        
        let content = UNMutableNotificationContent() // Содержимое уведомления
        content.title = "TastyBox"
        content.body = "Your Order Ready please collect it now"
        content.sound = UNNotificationSound.default
        content.badge = 1
        let date = Date(timeIntervalSinceNow: 1800)
        let triggerHourly = Calendar.current.dateComponents([.second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerHourly, repeats: true)
        let identifier = "Local Notification Order"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        notificationCenter.delegate = self
    }
}
