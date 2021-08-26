//
//  Constant.swift
//  Futbolist
//
//  Created by Adeel on 19/12/2019.
//  Copyright © 2019 Buzzware. All rights reserved.
//

import UIKit

struct Constant {
    
    
    static let v2 = "v2"
    static let version = "api/"
    static let mainUrl = "https://us-central1-pers-427bd.cloudfunctions.net"
    //https://us-central1-pers-427bd.cloudfunctions.net/sendHttpPushNotification
    //MARK: CACHE KEY'S
    static let login_key = "login_key"
    static let token_id = "token_id"
    static let notificationKey = "notificationKey"
    
    //MARK: DATABASE HELPER KEY
    static let cart = "cart"
    static let cid = "cid"
    
    //MARK: WEB SERVICE
    static let sucess = "sucess"
    static let success = "success"
    static let return_data = "return_data"
    static let image = "image"
    
    //MARK: MODELS KEY'S
    static let id = "id"
    static let receiverId = "receiverId"
    static let senderId = "senderId"
    static let receiverRecord = "receiverRecord"
    static let requester = "requester"
    static let email = "email"
    static let full_name = "full_name"
    static let location = "location"
    static let mobilenumber = "mobilenumber"
    static let password = "password"
    static let address_name = "address_name"
    static let address = "address"
    static let address_lat = "address_lat"
    static let address_lng = "address_lng"
    static let imageURL = "imageURL"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let name = "name"
    static let number = "number"
    static let isFriend = "isFriend"
    static let country = "country"
    static let zipCode = "zipCode"
    static let state = "state"
    static let city = "city"
    static let address1 = "address1"
    static let address2 = "address2"
    static let thumbnail = "thumbnail"
    static let uploaderID = "uploaderID"
    static let videoLatitude = "videoLatitude"
    static let videoLocation = "videoLocation"
    static let videoLongitude = "videoLongitude"
    static let videoURL = "videoURL"
    static let token = "token"
    static let title = "title"
    static let detail = "detail"
    static let timestamp = "timestamp"
    static let userImage = "userImage"
    static let userName = "userName"
    
    
    //MARK:- OTHER STATIC VARIABLE'S
    static let MapStyle = "[{\"featureType\":\"all\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#242f3e\"}]},{\"featureType\":\"all\",\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"lightness\":-80}]},{\"featureType\":\"administrative\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#746855\"}]},{\"featureType\":\"administrative.locality\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#d59563\"}]},{\"featureType\":\"poi\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#d59563\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#263c3f\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#6b9a76\"}]},{\"featureType\":\"road\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#2b3544\"}]},{\"featureType\":\"road\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#9ca5b3\"}]},{\"featureType\":\"road.arterial\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#38414e\"}]},{\"featureType\":\"road.arterial\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#212a37\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#746855\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#1f2835\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#f3d19c\"}]},{\"featureType\":\"road.local\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#38414e\"}]},{\"featureType\":\"road.local\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#212a37\"}]},{\"featureType\":\"transit\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#2f3948\"}]},{\"featureType\":\"transit.station\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#d59563\"}]},{\"featureType\":\"water\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#17263c\"}]},{\"featureType\":\"water\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#515c6d\"}]},{\"featureType\":\"water\",\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"lightness\":-20}]}]"
    
    static let usersTable = "Users"
    static let videosTable = "Videos"
    static let myVideosTable = "MyVideos"
    static let friendsTable = "Friends"
    static let userTableTokenKey = "token"
    static let dateFormat = "yyyyMMddHHmmss"
    static let mainStotyboard = "Main"
    static let locationTitle = "Location Not Found"
    static let notificationTitle = "New video uploaded"
    static let internetMsg = "Internet is unavailable please check your connection"
    static let locationMsg = "Your location not found please enable your location from settings"
    static let username = "username"
    static let uploaderid = "uploaderid"
    static let userimage = "userimage"
    
    //MARK: VIEW CONTROLLER IDENTIFIERS
    static let tabbarIdentifier = "Tabbar"
    static let mapVideoPlayerViewController = "MapVideoDetailViewController"
}
