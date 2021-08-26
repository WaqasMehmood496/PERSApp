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
    var thumbnail:String!
    var timestamp:String!
    var uploaderid:String!
    var userimage:String!
    var videoLatitude:String!
    var videoLocation:String!
    var videoLongitude:String!
    var videoURL:String!

    init(title:String? = nil,detail: String? = nil,videoLatitude: String? = nil,videoLocation: String? = nil,videoLongitude:String? = nil,videoURL: String? = nil,timestamp:String? = nil,thumbnail:String? = nil,uploaderid:String? = nil,userimage:String? = nil) {
       
        self.title = title
        self.detail = detail
        self.thumbnail = thumbnail
        self.timestamp = timestamp
        self.uploaderid = uploaderid
        self.userimage = userimage
        self.videoLatitude = videoLatitude
        self.videoLocation = videoLocation
        self.videoLongitude = videoLongitude
        self.videoURL = videoURL
    }
    
    init?(dic:NSDictionary) {
        
        let title = (dic as AnyObject).value(forKey: Constant.title) as! String
        let detail = (dic as AnyObject).value(forKey: Constant.detail) as! String
        let thumbnail = (dic as AnyObject).value(forKey: Constant.thumbnail) as! String
        let timestamp = (dic as AnyObject).value(forKey: Constant.timestamp) as! String
        let uploaderid = (dic as AnyObject).value(forKey: Constant.uploaderid) as! String
        let userimage = (dic as AnyObject).value(forKey: Constant.userimage) as! String
        let videoLatitude = (dic as AnyObject).value(forKey: Constant.videoLatitude) as! String
        let videoLocation = (dic as AnyObject).value(forKey: Constant.videoLocation) as! String
        let videoLongitude = (dic as AnyObject).value(forKey: Constant.videoLongitude) as! String
        let videoURL = (dic as AnyObject).value(forKey: Constant.videoURL) as! String
        
        self.title = title
        self.detail = detail
        self.thumbnail = thumbnail
        self.timestamp = timestamp
        self.uploaderid = uploaderid
        self.userimage = userimage
        self.videoLongitude = videoLongitude
        self.videoLocation = videoLocation
        self.videoLatitude = videoLatitude
        self.videoURL = videoURL
    }
}
