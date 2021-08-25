//
//  FriendRequestModel.swift
//  PERS
//
//  Created by Buzzware Tech on 18/06/2021.
//

import Foundation
import FirebaseDatabase

class AllRequestModel: Codable {
    var receiverId:String!
    var requester: [FriendRequestModel]!
    
    init(receiverId: String? = nil,requester: [FriendRequestModel]? = nil) {
        self.receiverId = receiverId
        self.requester = requester
    }
    
    init?(dic:DataSnapshot) {
        let receiverId = dic.key
        if dic.hasChildren(){
            
            let requester = dic.children.allObjects as NSArray
            var array = [FriendRequestModel]()
            for req in requester{
                array.append(FriendRequestModel(dic: req as! DataSnapshot)!)
            }
            
            self.receiverId = receiverId
            self.requester = array
        }
        

    }
}

class FriendRequestModel: Codable {
    
    var id:String!
    var imageURL:String!
    var name:String!
    
    init(id: String? = nil, imageURL: String? = nil, name: String? = nil) {
        self.id = id
        self.imageURL = imageURL
        self.name = name
    }
    
    init?(dic:DataSnapshot) {
        let id = dic.key
        self.id = id
        if let data = dic.value as? NSDictionary{
            let imageURL = data.value(forKey: Constant.imageURL) as? String
            let name = data.value(forKey: Constant.name) as? String
            self.imageURL = imageURL
            self.name = name
        }
    }
}


