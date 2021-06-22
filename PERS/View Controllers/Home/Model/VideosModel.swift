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

    init(id:String? = nil,thumbnail: String? = nil,uploaderID: String? = nil,videoLatitude: String? = nil,videoLocation: String? = nil,videoLongitude:String? = nil,videoURL: String? = nil) {
        self.id = id
        self.thumbnail = thumbnail
        self.uploaderID = uploaderID
        self.videoLatitude = videoLatitude
        self.videoLocation = videoLocation
        self.videoLongitude = videoLongitude
        self.videoURL = videoURL
    }
    
    init?(dic:NSDictionary) {
        
        let id = (dic as AnyObject).value(forKey: Constant.id) as! String
        let thumbnail = (dic as AnyObject).value(forKey: Constant.thumbnail) as! String
        let uploaderID = (dic as AnyObject).value(forKey: Constant.uploaderID) as! String
        let videoLatitude = (dic as AnyObject).value(forKey: Constant.videoLatitude) as! String
        let videoLocation = (dic as AnyObject).value(forKey: Constant.videoLocation) as! String
        let videoLongitude = (dic as AnyObject).value(forKey: Constant.videoLongitude) as! String
        let videoURL = (dic as AnyObject).value(forKey: Constant.videoURL) as! String

        self.id = id
        self.thumbnail = thumbnail
        self.uploaderID = uploaderID
        self.videoLatitude = videoLatitude
        self.videoLocation = videoLocation
        self.videoLongitude = videoLongitude
        self.videoURL = videoURL
        
    }
}
