////
////  MapMarkerModel.swift
////  PastaRecipe
////
////  Created by Waqas on 15/12/2020.
////  Copyright © 2020 Buzzware. All rights reserved.
////
//
//import Foundation
//
//class MapMarkerModel:Codable{
//  var image_url:String!
//  var store_id:String!
//  var title:String!
//  var descrip:String!
//  var address:String!
//  var lat: String!
//  var lng: String!
//  var distance: String!
//  init(image_url: String? = nil,store_id: String? = nil,title: String? = nil,descrip: String? = nil,address: String? = nil,lat: String? = nil,distance: String? = nil,lng: String? = nil) {
//    self.image_url = image_url
//    self.store_id = store_id
//    self.title  = title
//    self.descrip = descrip
//    self.address = address
//    self.lat = lat
//    self.lng = lng
//    self.distance = distance
//  }
//  init?(dic:NSDictionary) {
//    let image_url = (dic as AnyObject).value(forKey: Constant.image_url) as? String
//    let store_id = (dic as AnyObject).value(forKey: Constant.store_id) as? String
//    let title = (dic as AnyObject).value(forKey: Constant.title) as? String
//    let descrip = (dic as AnyObject).value(forKey: Constant.descrip) as? String
//    let address = (dic as AnyObject).value(forKey: Constant.address) as? String
//    let lat = (dic as AnyObject).value(forKey: Constant.lat) as? String
//    let lng = (dic as AnyObject).value(forKey: Constant.lng) as? String
//    let distance = (dic as AnyObject).value(forKey: Constant.distance) as? String
//    self.image_url = image_url
//    self.store_id = store_id
//    self.title = title
//    self.descrip = descrip
//    self.address = address
//    self.lat = lat
//    self.lng = lng
//    self.distance = distance
//  }
//}
