//
//  FriendRequestModel.swift
//  PERS
//
//  Created by Buzzware Tech on 18/06/2021.
//

import Foundation

class FriendRequestModel: Codable {
    
    var id:String!
    var imageURL:String!
    var name:String!
    init(id: String? = nil, imageURL: String? = nil, name: String? = nil) {
        self.id = id
        self.imageURL = imageURL
        self.name = name
    }
    
    init?(dic:NSDictionary) {
        let id = (dic as AnyObject).value(forKey: Constant.id) as! String
        let imageURL = (dic as AnyObject).value(forKey: Constant.imageURL) as! String
        let name = (dic as AnyObject).value(forKey: Constant.name) as! String
        
        self.id = id
        self.imageURL = imageURL
        self.name = name
    }
}
