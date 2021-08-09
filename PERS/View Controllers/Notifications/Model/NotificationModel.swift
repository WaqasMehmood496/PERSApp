//
//  NotificationModel.swift
//  PERS
//
//  Created by Buzzware Tech on 02/07/2021.
//

import Foundation
import Foundation

class NotificationModel: Codable {
    
    var title: String!
    var detail:String!
    
    var uploaderID:String!
    var videoLatitude:String!
    var videoLocation:String!
    var videoLongitude:String!
    var videoURL:String!
    var timestamp:String!
    
    init(title:String? = nil,detail: String? = nil,uploaderID: String? = nil,videoLatitude: String? = nil,videoLocation: String? = nil,videoLongitude:String? = nil,videoURL: String? = nil,timestamp:String? = nil) {
        self.title = title
        self.detail = detail
        self.uploaderID = uploaderID
        self.videoLatitude = videoLatitude
        self.videoLocation = videoLocation
        self.videoLongitude = videoLongitude
        self.videoURL = videoURL
        self.timestamp = timestamp
    }
    
    init?(dic:NSDictionary) {
        
        let title = (dic as AnyObject).value(forKey: Constant.title) as! String
        let detail = (dic as AnyObject).value(forKey: Constant.detail) as! String
        let uploaderID = (dic as AnyObject).value(forKey: Constant.uploaderID) as! String
        let videoLatitude = (dic as AnyObject).value(forKey: Constant.videoLatitude) as! String
        let videoLocation = (dic as AnyObject).value(forKey: Constant.videoLocation) as! String
        let videoLongitude = (dic as AnyObject).value(forKey: Constant.videoLongitude) as! String
        let videoURL = (dic as AnyObject).value(forKey: Constant.videoURL) as! String
        let timestamp = (dic as AnyObject).value(forKey: Constant.timestamp) as? String
        
        self.title = title
        self.detail = detail
        self.uploaderID = uploaderID
        self.videoLatitude = videoLatitude
        self.videoLocation = videoLocation
        self.videoLongitude = videoLongitude
        self.videoURL = videoURL
        self.timestamp = timestamp
        
    }
}
