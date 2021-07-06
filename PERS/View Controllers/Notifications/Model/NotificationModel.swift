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

    init(title:String? = nil,detail: String? = nil) {
        self.title = title
        self.detail = detail

    }
    
    init?(dic:NSDictionary) {
        
        let title = (dic as AnyObject).value(forKey: Constant.title) as! String
        let detail = (dic as AnyObject).value(forKey: Constant.detail) as! String
        
        self.title = title
        self.detail = detail
  
    }
}
