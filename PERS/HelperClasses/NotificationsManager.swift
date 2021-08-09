//
//  NotificationsManager.swift
//  PERS
//
//  Created by Buzzware Tech on 23/06/2021.
//

import Foundation
import UIKit
import SwiftyJSON
class PushNotificationSender {
    
    func sendPushNotification(to token: String, title: String, body: String, data:[String:Any]) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title,
                                                             "body": body],
                                           "data" : data
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAy6h7Zs4:APA91bFEciRz7muvUb46xNznTbR5fXQAZnnPHS5I9F-84QYj716F5gJTSzW7tO6-Re9lbsu33qO_fhJOXpWd7MtC680Rd3HUlpqUricJ4odrIKoAwpEkbtfh0THYtBpX_EBR4vDbq7wv", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                        print(jsonDataDict)
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
