//
//  LocationModel.swift
//  PERS
//
//  Created by Buzzware Tech on 16/06/2021.
//

import Foundation
class LocationModel:Codable {
    
    var address_name:String!
    var address:String!
    var street_address_1:String!
    var street_address_2:String!
    var zipcode:String!
    var city:String!
    var state:String!
    var country:String!
    var address_lat:String!
    var address_lng:String!
    
    init(address_name:String? = nil,address:String? = nil,street_address_1:String? = nil,street_address_2:String? = nil,zipcode:String? = nil,city:String? = nil,state_id:String? = nil,country_id:String? = nil,address_lat:String? = nil,address_lng:String? = nil) {
        self.address_name = address_name
        self.address = address
        self.street_address_1 = street_address_1
        self.street_address_2 = street_address_2
        self.zipcode = zipcode
        self.city = city
        self.state = state_id
        self.country = country_id
        self.address_lat = address_lat
        self.address_lng = address_lng
    }
    
    init?(dic:NSDictionary) {
        
        
        let address_name = (dic as AnyObject).value(forKey: Constant.address_name) as? String
        let address = (dic as AnyObject).value(forKey: Constant.address) as? String
        let address_lat = (dic as AnyObject).value(forKey: Constant.address_lat) as? String
        let address_lng = (dic as AnyObject).value(forKey: Constant.address_lng) as? String
        let zipCode = (dic as AnyObject).value(forKey: Constant.zipCode) as? String
        let state = (dic as AnyObject).value(forKey: Constant.state) as? String
        let city = (dic as AnyObject).value(forKey: Constant.city) as? String
        let country = (dic as AnyObject).value(forKey: Constant.country) as? String
        let address1 = (dic as AnyObject).value(forKey: Constant.address1) as? String
        let address2 = (dic as AnyObject).value(forKey: Constant.address2) as? String
        
        
        
        self.address_name = address_name
        self.address = address
        self.address_lat = address_lat
        self.address_lng = address_lng
        self.street_address_1 = address1
        self.street_address_2 = address2
        self.zipcode = zipCode
        self.city = city
        self.state = state
        self.country = country
    }
}
