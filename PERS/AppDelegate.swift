//
//  AppDelegate.swift
//  PERS
//
//  Created by Buzzware Tech on 09/06/2021.
//

import UIKit
//import GoogleMaps
//import GooglePlaces
import FirebaseCore
import FirebaseMessaging
import FirebaseInstallations
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var deviceTokenForPushN = ""
    
    override init() {
        super .init()
        FirebaseApp.configure()
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        //checkUserAlreadyLogin()
        //IQKeyboardManager.shared.enable = true
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
}
extension AppDelegate{
    //    func checkUserAlreadyLogin() {
    //        var storyboard :UIStoryboard!
    //        if UIDevice.current.userInterfaceIdiom == .phone{
    //            storyboard = UIStoryboard(name: "Main", bundle: nil)
    //        }
    //        else{
    //            storyboard = UIStoryboard(name: "Ipad", bundle: nil)
    //        }
    //        if (CommonHelper.getCachedUserData()?.id != nil){
    //            let controller = storyboard.instantiateViewController(identifier: "LGSideMenuController") as! UINavigationController
    //            self.window?.rootViewController = controller
    //        }else{
    //            let controller = storyboard.instantiateViewController(identifier: "SignInViewController") as! UINavigationController
    //            self.window?.rootViewController = controller
    //        }
    //        self.window?.makeKeyAndVisible()
    //    }
}
extension AppDelegate:UNUserNotificationCenterDelegate{
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
        print ("the user info is " , userInfo )
        //      let str = String(describing: userInfo)
        //
        //      let arr = str.components(separatedBy: ",")
        //
        //    let arr2 = arr.filter { (val) -> Bool in
        //      return val.contains("status")
        //    }
        //    if arr2.count > 0{
        //      let arr3 = arr2[0].components(separatedBy: ":")
        //      print("the arr2 is" , arr3)
        //      let type = arr3.last
        //
        //      print("the type is" , type!)
        //
        //      let typ = type?.replacingOccurrences(of: " ", with: "")
        //      if typ == "1"{
        //        self.userNotify()
        //        //self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(userNotify), userInfo: nil, repeats: true)
        //
        //      }
        //    }
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