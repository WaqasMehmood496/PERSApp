//
//  VideosModel.swift
//  PERS
//
//  Created by Buzzware Tech on 21/06/2021.
//

import Foundation
class VideosModel: Codable {
    
    var id: String!
    var thumbnail:String!
    var uploaderID:String!
    var videoLatitude:String!
    var videoLocation:String!
    var videoLongitude:String!
    var videoURL:String!
    var timestamp:String!
    var userName:String!
    var userImage:String!
    
    init(id:String? = nil,thumbnail: String? = nil,uploaderID: String? = nil,videoLatitude: String? = nil,videoLocation: String? = nil,videoLongitude:String? = nil,videoURL: String? = nil,timestamp:String? = nil,userName:String? = nil,userImage:String? = nil) {
        self.id = id
        self.thumbnail = thumbnail
        self.uploaderID = uploaderID
        self.videoLatitude = videoLatitude
        self.videoLocation = videoLocation
        self.videoLongitude = videoLongitude
        self.videoURL = videoURL
        self.timestamp = timestamp
        self.userName = userName
        self.userImage = userImage
    }
    
    init?(dic:NSDictionary) {
        
        let id = (dic as AnyObject).value(forKey: Constant.id) as! String
        let thumbnail = (dic as AnyObject).value(forKey: Constant.thumbnail) as! String
        let uploaderID = (dic as AnyObject).value(forKey: Constant.uploaderID) as! String
        let videoLatitude = (dic as AnyObject).value(forKey: Constant.videoLatitude) as! String
        let videoLocation = (dic as AnyObject).value(forKey: Constant.videoLocation) as! String
        let videoLongitude = (dic as AnyObject).value(forKey: Constant.videoLongitude) as! String
        let videoURL = (dic as AnyObject).value(forKey: Constant.videoURL) as! String
        let timestamp = (dic as AnyObject).value(forKey: Constant.timestamp) as? String
        let userName = (dic as AnyObject).value(forKey: Constant.userName) as? String
        let userImage = (dic as AnyObject).value(forKey: Constant.userImage) as? String
        
        self.id = id
        self.thumbnail = thumbnail
        self.uploaderID = uploaderID
        self.videoLatitude = videoLatitude
        self.videoLocation = videoLocation
        self.videoLongitude = videoLongitude
        self.videoURL = videoURL
        self.timestamp = timestamp
        self.userName = userName
        self.userImage = userImage
    }
}
