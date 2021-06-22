////
////  DataBaseHelper.swift
////  MandiCart
////
////  Created by Adeel on 14/03/2020.
////  Copyright © 2020 Buzzware. All rights reserved.
////
//
//import UIKit
//import SQLite
//class DataBaseHelper {
//
//    static let sharedInstance = DataBaseHelper() //<- Singleton Instance
//    var db : Connection!
//    var isFirstTime : Bool = false
//    let cart = Table(Constant.cart)
//    let cid = Expression<Int64>(Constant.cid)
//    let id = Expression<Int64>(Constant.id)
//    let image_url = Expression<String?>(Constant.image_url)
//    let name = Expression<String>(Constant.name)
//    let price = Expression<Double>(Constant.price)
//    let price_per_case = Expression<Double?>(Constant.price_per_case)
//    let qty_per_case = Expression<Double?>(Constant.qty_per_case)
//    let unit = Expression<Double>(Constant.unit)
//       private init() {
//        do{
//            let name = CommonHelper.sharedInstance.getDirectoryPath()
//            db = try Connection(name)
//            if !isFirstTime{
//                creatTable()
//                isFirstTime = true
//            }
//            
//        }
//        catch{
//            debugPrint(error)
//        }
//        
//        /* Additional instances cannot be created */ }
//    
//    func creatTable(){
//    
//        do{
//            try db.run(cart.create(block: { (t) in
//                t.column(cid, primaryKey: true)
//                t.column(id, unique: true)
//                t.column(image_url)
//                t.column(name)
//                t.column(price)
//                t.column(price_per_case)
//                t.column(qty_per_case)
//                t.column(unit)
//            }))
//        }
//        catch{
//            debugPrint(error)
//        }
//        
//    }
//    func saveToCart(arry:[CartModel]) -> Bool{
//        
//        var suces = false
//        for data in arry{
//            do{
//                try db.run(cart.insert(cid <- Int64(Date().milisecond),id <- data.id!,image_url <- data.image_url,name <- data.name!,price <- data.price!,price_per_case <- data.price_per_case,qty_per_case <- data.qty_per_case,unit <- data.unit!))
//                suces = true
//            }
//            catch{
//                debugPrint(error)
//                do{
//                    let rid = cart.filter(id == data.id!)
//                    try db.run(rid.update(price <- data.price,price_per_case <- data.price_per_case,qty_per_case <- data.qty_per_case,unit <- data.unit))
//                    suces = true
//                }
//                catch{
//                    debugPrint(error)
//                    suces = false
//                }
//            }
//            
//        }
//        return suces
//    }
//    func getCart() -> Int{
//        do{
//            let result = try db.scalar(cart.count)
//            return result
//        }
//        catch{
//            debugPrint(error)
//            return 0
//        }
//    }
//    func getAllCart()->[CartModel]{
//        var array = [CartModel]()
//        do{
//            
//            for result in try db.prepare(cart.select(id,image_url,name,price,price_per_case,qty_per_case,unit)){
//                
//                array.append(CartModel(id: try result.get(id), image_url: try result.get(image_url), name: try result.get(name), price: try result.get(price), price_per_case: try result.get(price_per_case), qty_per_case: try result.get(qty_per_case), unit: try result.get(unit)))
//            }
//            return array
//        }
//        catch{
//            debugPrint(error)
//            return array
//        }
//        
//    }
////    func getAllInvoice()->[InvoiceModel]{
////        var array = [InvoiceModel]()
////        do{
////
////            for result in try db.prepare(cart.select(id,imageURL,name,price,rating,stock,unit,cartPrice,cartKg)){
////
////                array.append(InvoiceModel(id: try result.get(id), image: try result.get(imageURL), name:  try result.get(name), price: try result.get(price), productCount: try result.get(cartKg), rating: try result.get(rating), stock: try result.get(stock), subTotal: try result.get(cartPrice), unit: try result.get(unit)))
////            }
////            return array
////        }
////        catch{
////            debugPrint(error)
////            return array
////        }
////
////    }
////    func getAllInvoices()->[InvoicesModel]{
////        var array = [InvoicesModel]()
////        do{
////
////            for result in try db.prepare(cart.select(id,imageURL,name,price,rating,stock,unit,cartPrice,cartKg)){
////
////                array.append(InvoicesModel(id: try result.get(id), image: try result.get(imageURL), name:  try result.get(name), price: try result.get(price), productCount: try result.get(cartKg), rating: try result.get(rating), stock: try result.get(stock), subTotal: "\(try result.get(cartPrice))", unit: try result.get(unit)))
////            }
////            return array
////        }
////        catch{
////            debugPrint(error)
////            return array
////        }
////
////    }
//    func deleteAllCart(array: [CartModel]) -> Bool{
//        var suces = false
//        for data in array{
//            do{
//                let rid = cart.filter(id == data.id!)
//                try db.run(rid.delete())
//                suces = true
//            }
//            catch{
//                debugPrint(error)
//                suces = false
//            }
//        }
//        return suces
//    }
////    func deleteAllCart1(array: [InvoiceModel]) -> Bool{
////        var suces = false
////        for data in array{
////            do{
////                let rid = cart.filter(id == data.id!)
////                try db.run(rid.delete())
////                suces = true
////            }
////            catch{
////                debugPrint(error)
////                suces = false
////            }
////        }
////        return suces
////    }
//    func deleteCart(data: CartModel) -> Bool{
//        var suces = false
//        do{
//            let rid = cart.filter(id == data.id!)
//            try db.run(rid.delete())
//            suces = true
//        }
//        catch{
//            debugPrint(error)
//            suces = false
//        }
//        return suces
//    }
////    func deleteCart1(data: InvoiceModel) -> Bool{
////        var suces = false
////        do{
////            let rid = cart.filter(id == data.id!)
////            try db.run(rid.delete())
////            suces = true
////        }
////        catch{
////            debugPrint(error)
////            suces = false
////        }
////        return suces
////    }
//    func updateCart(data: CartModel) -> Bool{
//        var suces = false
//        do{
//            let rid = cart.filter(id == data.id!)
//            try db.run(rid.update(price <- data.price,price_per_case <- data.price_per_case,qty_per_case <- data.qty_per_case,unit <- data.unit))
//            suces = true
//        }
//        catch{
//            debugPrint(error)
//            suces = false
//        }
//        return suces
//    }
//}
