//
//  WebServicesHelper.swift
//  TradeAir
//
//  Created by Adeel on 08/10/2019.
//  Copyright © 2019 Buzzware. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON
import JGProgressHUD
enum webserviceUrl: String {
    
    //Login Storyboard
    case login = "/auth/login",
    socialLogIn = "/auth/social"
    
    func url() -> String {
        return Constant.mainUrl + self.rawValue
    }
}

class WebServicesHelper
{
    
    var serviceName:webserviceUrl!
    var httpMethodName:HTTPMethod!
    var parameters:[String:Any]?
    var relatedViewController:UIViewController?
    var hud:JGProgressHUD?

    
    // MARK: - Web Service Base Url
    
    
    init(serviceToCall serviceName:webserviceUrl,
         withMethod httpMethodName:HTTPMethod,
         havingParameters parameters:[String:Any]? = nil,
         relatedViewController:UIViewController?,hud: JGProgressHUD? = nil)
    {
        self.serviceName = serviceName
        self.httpMethodName = httpMethodName
        self.parameters = parameters
        self.relatedViewController = relatedViewController
        self.hud = hud
    }

    weak var delegateForWebServiceResponse: WebServiceResponseDelegate?
    
    class func callWebService(Parameters params : [String : Any]? = nil,suburl:String? = nil ,action : webserviceUrl!,httpMethodName: HTTPMethod!,_ index:Int? = nil, completion: @escaping (Int?,webserviceUrl,Bool,String?,Any?) -> Void){
        
        
        var base_url:String
        if let sub = suburl {
            base_url = action.url()  + sub
        }
        else{
            base_url = action.url()
        }
        print(base_url)
        let myheaders:HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded","Accept":"application/json"]
//        var myheaders:HTTPHeaders = ["Content-Type":"application/json"]
//        if let token = CommonHelper.getCachedUserData()?.token{
//            myheaders["Authorization"] = "Bearer " + token
//        }
        
        var encoding:ParameterEncoding!
        if httpMethodName == .get {
            encoding = URLEncoding.default
        }
        else{
            encoding = JSONEncoding.default
        }
        if (Alamofire.NetworkReachabilityManager()?.isReachable)! {
            AF.request(base_url, method: httpMethodName, parameters: params, encoding: encoding, headers: myheaders).responseJSON { (response) in
                var statusCode:NSInteger? = nil
                if let responseObj: HTTPURLResponse = response.response
                {
                    statusCode = responseObj.statusCode
                }
                
                if let error = response.error
                {
                    statusCode = error._code // statusCode private
                    switch error
                    {
                    case .invalidURL(let url):
                        let string = "Invalid URL: \(url) - \(error.localizedDescription)"
                         print(string)
                        completion(index,action,true,string,nil)
                        
                        
                    case .parameterEncodingFailed(let reason):
                        let string = "Parameter encoding failed: \(error.localizedDescription) - Failure Reason: \(reason)"
                        print(string)
                        completion(index,action,true,string,nil)
                        
                    case .multipartEncodingFailed(let reason):
                        let string = "Multipart encoding failed: \(error.localizedDescription) - Failure Reason: \(reason)"
                        print(string)
                        completion(index,action,true,string,nil)
                        
                    case .responseValidationFailed(let reason):
                        let string = "Response validation failed: \(error.localizedDescription) - Failure Reason: \(reason)"
                        print(string)
                        completion(index,action,true,string,nil)
                        switch reason
                        {
                            
                        case .dataFileNil, .dataFileReadFailed:
                            let string = "Downloaded file could not be read"
                            print(string)
                            completion(index,action,true,string,nil)
                            
                        case .missingContentType(let acceptableContentTypes):
                            let string = "Content Type Missing: \(acceptableContentTypes)"
                            print(string)
                            completion(index,action,true,string,nil)
                            
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            let string = "Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)"
                            print(string)
                            completion(index,action,true,string,nil)
                            
                        case .unacceptableStatusCode(let code):
                            let string = "Response status code was unacceptable: \(code)"
                            print(string)
                            statusCode = code
                            completion(index,action,true,string,nil)
                        default:
                            completion(index,action,true,error.localizedDescription,nil)
                        }
                        
                    case .responseSerializationFailed(let reason):
                        let string = "Response serialization failed: \(error.localizedDescription) - Failure Reason: \(reason)"
                        completion(index,action,true,string,nil)
                        // statusCode = 3840 ???? maybe..
                    default:
                        completion(index,action,true,error.localizedDescription,nil)
                    }
                    
                    
                    print("Underlying error: \(String(describing: error.underlyingError))")
                }
                else if let error = response.error
                {
                    let string = "URLError occurred: \(error)"
                    print(string)
                    completion(index,action,true,string,nil)
                }
                else
                {
                    let string = "Unknown error: \(String(describing: response.error))"
                    print(string)
                    //completion(true,string,nil)
                    
                }
                
                if statusCode == nil{
                    completion(index,action,true,response.error?.localizedDescription,nil)
                    return
                }
                if((response.value) != nil)
                {
                    let swiftyJsonVar = JSON(response.value!)
                    
                    if let jsonDict:Dictionary<String, Any> = swiftyJsonVar.dictionaryObject
                    {
                        let responseStatus:Int? = jsonDict[Constant.sucess] as? Int
                        let responseStatus1:Int? = jsonDict[Constant.success] as? Int
                        if(responseStatus == 0 || responseStatus1 == 0)
                        {
                            completion(index,action,true,"error",nil)
                            
                        }
                        else{
                            if let responseDic = jsonDict[Constant.return_data]{
                                completion(index,action,true,nil,responseDic)
                            }
                            else{
                                completion(index,action,true,nil,jsonDict)
                            }
                        }
                    }
                    else{
                        completion(index,action,true,swiftyJsonVar.error?.localizedDescription,nil)
                    }
                }
                else{
                    completion(index,action,true,response.error?.localizedDescription,nil)
                }
            }
            
        }
        else{
            completion(index,action,false,nil,nil)
        }
    }
    
    class func callWebServiceWithFileUpload(Parameters params : [String : Any]? ,suburl:String? = nil,imageData:Data? = nil,action : webserviceUrl!,httpMethodName: HTTPMethod!,_ index:Int? = nil, completion: @escaping (Int?,webserviceUrl,Bool,String?,Any?) -> Void){
        
        let base_url:String
        if let urll = suburl{
            base_url = action.url() + urll
        }
        else{
            base_url = action.url()
        }
        print(base_url)
        
        let myheaders: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        if (Alamofire.NetworkReachabilityManager()?.isReachable)! {
            AF.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in params!
                {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                
                if let data = imageData
                {
                    multipartFormData.append(data, withName: "image", fileName: "image.png", mimeType: "image/png")
                }
            }, to: base_url, usingThreshold: UInt64.init(), method: httpMethodName, headers: myheaders).responseJSON { (response) in
                
                var statusCode:NSInteger? = nil
                if let responseObj: HTTPURLResponse = response.response
                {
                    statusCode = responseObj.statusCode
                }
                
                if let error = response.error
                {
                    statusCode = error._code // statusCode private
                    switch error
                    {
                    case .invalidURL(let url):
                        let string = "Invalid URL: \(url) - \(error.localizedDescription)"
                         print(string)
                        completion(index,action,true,string,nil)
                        
                        
                    case .parameterEncodingFailed(let reason):
                        let string = "Parameter encoding failed: \(error.localizedDescription) - Failure Reason: \(reason)"
                        print(string)
                        completion(index,action,true,string,nil)
                        
                    case .multipartEncodingFailed(let reason):
                        let string = "Multipart encoding failed: \(error.localizedDescription) - Failure Reason: \(reason)"
                        print(string)
                        completion(index,action,true,string,nil)
                        
                    case .responseValidationFailed(let reason):
                        let string = "Response validation failed: \(error.localizedDescription) - Failure Reason: \(reason)"
                        print(string)
                        completion(index,action,true,string,nil)
                        switch reason
                        {
                            
                        case .dataFileNil, .dataFileReadFailed:
                            let string = "Downloaded file could not be read"
                            print(string)
                            completion(index,action,true,string,nil)
                            
                        case .missingContentType(let acceptableContentTypes):
                            let string = "Content Type Missing: \(acceptableContentTypes)"
                            print(string)
                            completion(index,action,true,string,nil)
                            
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            let string = "Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)"
                            print(string)
                            completion(index,action,true,string,nil)
                            
                        case .unacceptableStatusCode(let code):
                            let string = "Response status code was unacceptable: \(code)"
                            print(string)
                            statusCode = code
                            completion(index,action,true,string,nil)
                        default:
                            completion(index,action,true,error.localizedDescription,nil)
                        }
                        
                    case .responseSerializationFailed(let reason):
                        let string = "Response serialization failed: \(error.localizedDescription) - Failure Reason: \(reason)"
                        completion(index,action,true,string,nil)
                        // statusCode = 3840 ???? maybe..
                    default:
                        completion(index,action,true,error.localizedDescription,nil)
                    }
                    
                    
                    print("Underlying error: \(String(describing: error.underlyingError))")
                }
                else if let error = response.error
                {
                    let string = "URLError occurred: \(error)"
                    print(string)
                    completion(index,action,true,string,nil)
                }
                else
                {
                    let string = "Unknown error: \(String(describing: response.error))"
                    print(string)
                    //completion(true,string,nil)
                    
                }
                
                if statusCode == nil{
                    completion(index,action,true,response.error?.localizedDescription,nil)
                    return
                }
                if((response.value) != nil)
                {
                    let swiftyJsonVar = JSON(response.value!)
                    
                    if let jsonDict:Dictionary<String, Any> = swiftyJsonVar.dictionaryObject
                    {
                        let responseStatus:Int? = jsonDict[Constant.sucess] as? Int
                        let responseStatus1:Int? = jsonDict[Constant.success] as? Int
                        if(responseStatus == 0 || responseStatus1 == 0)
                        {
                            completion(index,action,true,"error",nil)
                            
                        }
                        else{
                            if let responseDic = jsonDict[Constant.return_data]{
                                completion(index,action,true,nil,responseDic)
                            }
                            else{
                                completion(index,action,true,nil,jsonDict)
                            }
                        }
                    }
                    else{
                        completion(index,action,true,swiftyJsonVar.error?.localizedDescription,nil)
                    }
                }
                else{
                    completion(index,action,true,response.error?.localizedDescription,nil)
                }
            }
        }
        else{
            completion(index,action,false,nil,nil)
        }
    }
    func callWebService()
    {
        let serviceURL:String = self.serviceName.url()
        
        let myheaders:HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded","Accept":"application/json"]
        //let myheaders = ["Content-Type":"text/html; charset=UTF-8","Accept": "*/*"]
        
        AF.request(serviceURL, method: .post, parameters: self.parameters, encoding: URLEncoding.default, headers: myheaders)
            .responseJSON { response in
                
                
                //print(response.request as Any)  // original URL request
                //print(response.response as Any) // URL response
                //print(response.result.value as Any)   // result of response serialization
                
                
                var statusCode:NSInteger? = nil
                if let responseObj: HTTPURLResponse = response.response
                {
                    statusCode = responseObj.statusCode
                }
                
                if let error = response.error
                {
                    statusCode = error._code // statusCode private
                    switch error
                    {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url) - \(error.localizedDescription)")
                        self.hud?.textLabel.text = "Invalid URL: \(url) - \(error.localizedDescription)"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        self.hud?.textLabel.text = "Failure Reason: \(reason)"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        self.hud?.textLabel.text = "Failure Reason: \(reason)"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        self.hud?.textLabel.text = "Failure Reason: \(reason)"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        
                        switch reason
                        {
                        case .dataFileNil, .dataFileReadFailed:
                            print("Downloaded file could not be read")
                            self.hud?.textLabel.text = "Downloaded file could not be read"
                            self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud?.dismiss(afterDelay: 2, animated: true)
                            
                        case .missingContentType(let acceptableContentTypes):
                            print("Content Type Missing: \(acceptableContentTypes)")
                            
                            self.hud?.textLabel.text = "Content Type Missing: \(acceptableContentTypes)"
                            self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud?.dismiss(afterDelay: 2, animated: true)
                            
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                            
                            self.hud?.textLabel.text = "Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)"
                            self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud?.dismiss(afterDelay: 2, animated: true)
                            
                            
                        case .unacceptableStatusCode(let code):
                            print("Response status code was unacceptable: \(code)")
                            statusCode = code
                            self.hud?.textLabel.text = "Response status code was unacceptable: \(code)"
                            self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud?.dismiss(afterDelay: 2, animated: true)
                        default:
                            self.hud?.textLabel.text = error.localizedDescription
                            self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud?.dismiss(afterDelay: 2, animated: true)
                        }
                        
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        self.hud?.textLabel.text = error.localizedDescription
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        // statusCode = 3840 ???? maybe..
                    default:
                        print("Response serialization failed: \(error.localizedDescription)")
                        self.hud?.textLabel.text = error.localizedDescription
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                    }
                    
                    print("Underlying error: \(String(describing: error.underlyingError))")
                }
                else if let error = response.error
                {
                    print("URLError occurred: \(error)")
                    self.hud?.textLabel.text = error.localizedDescription
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                }
                else
                {
                    print("Unknown error: \(String(describing: response.error))")
                }
                
                
                
                print("Web Service Title = " + self.serviceName!.url())
                print("Web Service Status Code = \(String(describing: statusCode))")
                print("Web Service Response String = \(response.value ?? "No Response Found")")
                
                //                            let dataString = String(data: responseData.data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                //                            print(dataString!)
                
                
                if((response.value) != nil)
                {
                    let swiftyJsonVar = JSON(response.value!)
                    
                    if let jsonDict:Dictionary<String, Any> = swiftyJsonVar.dictionaryObject
                    {
                        //print("jsonDict = \(jsonDict)")
                        
                        let responseStatus:Int? = jsonDict[Constant.sucess] as? Int
                        let responseStatus1:Int? = jsonDict[Constant.success] as? Int
//                        guard let status = responseStatus, let status1 = responseStatus1 else {
//
//                            fatalError("[WebServiceRequestError] Status cannot be nil")
//
//
//                        }
                        
                        
                        if(responseStatus == 0 || responseStatus1 == 0)
                        {
                            self.hud!.textLabel.text = "error"
                            self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud?.dismiss(afterDelay: 2, animated: true)
                            
                            return
                        }
                        
                        if let responseDic = jsonDict[Constant.return_data]{
                            self.delegateForWebServiceResponse?.webServiceDataParsingOnResponseReceived(url: self.serviceName ,viewControllerObj: self.relatedViewController!,dataDict: responseDic,hud: self.hud!)
                        }
                        else{
                            self.delegateForWebServiceResponse?.webServiceDataParsingOnResponseReceived(url: self.serviceName,viewControllerObj: self.relatedViewController,dataDict: jsonDict,hud: self.hud!)
                        }
                        
                        
                    }
                }
                
        }
        
    }
    func callWebService(val:String)
        {
            let serviceURL:String = self.serviceName.url() + val
            
            let myheaders:HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded","Accept":"application/json"]
            //let myheaders = ["Content-Type":"text/html; charset=UTF-8","Accept": "*/*"]
        AF.request(serviceURL, method: .post, parameters: self.parameters, encoding: URLEncoding.default, headers: myheaders)
                .responseJSON { response in
                    
                    
                    var statusCode:NSInteger? = nil
                    if let responseObj: HTTPURLResponse = response.response
                    {
                        statusCode = responseObj.statusCode
                    }
                    
                    if let error = response.error
                    {
                        statusCode = error._code // statusCode private
                        switch error
                        {
                        case .invalidURL(let url):
                            print("Invalid URL: \(url) - \(error.localizedDescription)")
                            self.hud?.textLabel.text = "Invalid URL: \(url) - \(error.localizedDescription)"
                            self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud?.dismiss(afterDelay: 2, animated: true)
                            
                        case .parameterEncodingFailed(let reason):
                            print("Parameter encoding failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                            self.hud?.textLabel.text = "Failure Reason: \(reason)"
                            self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud?.dismiss(afterDelay: 2, animated: true)
                            
                        case .multipartEncodingFailed(let reason):
                            print("Multipart encoding failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                            self.hud?.textLabel.text = "Failure Reason: \(reason)"
                            self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud?.dismiss(afterDelay: 2, animated: true)
                            
                        case .responseValidationFailed(let reason):
                            print("Response validation failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                            self.hud?.textLabel.text = "Failure Reason: \(reason)"
                            self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud?.dismiss(afterDelay: 2, animated: true)
                            
                            switch reason
                            {
                            case .dataFileNil, .dataFileReadFailed:
                                print("Downloaded file could not be read")
                                self.hud?.textLabel.text = "Downloaded file could not be read"
                                self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                                self.hud?.dismiss(afterDelay: 2, animated: true)
                                
                            case .missingContentType(let acceptableContentTypes):
                                print("Content Type Missing: \(acceptableContentTypes)")
                                
                                self.hud?.textLabel.text = "Content Type Missing: \(acceptableContentTypes)"
                                self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                                self.hud?.dismiss(afterDelay: 2, animated: true)
                                
                            case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                                print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                                
                                self.hud?.textLabel.text = "Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)"
                                self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                                self.hud?.dismiss(afterDelay: 2, animated: true)
                                
                                
                            case .unacceptableStatusCode(let code):
                                print("Response status code was unacceptable: \(code)")
                                statusCode = code
                                self.hud?.textLabel.text = "Response status code was unacceptable: \(code)"
                                self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                                self.hud?.dismiss(afterDelay: 2, animated: true)
                            default:
                                self.hud?.textLabel.text = error.localizedDescription
                                self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                                self.hud?.dismiss(afterDelay: 2, animated: true)
                            }
                            
                        case .responseSerializationFailed(let reason):
                            print("Response serialization failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                            self.hud?.textLabel.text = error.localizedDescription
                            self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud?.dismiss(afterDelay: 2, animated: true)
                            // statusCode = 3840 ???? maybe..
                        default:
                            print("Response serialization failed: \(error.localizedDescription)")
                            self.hud?.textLabel.text = error.localizedDescription
                            self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud?.dismiss(afterDelay: 2, animated: true)
                        }
                        
                        print("Underlying error: \(String(describing: error.underlyingError))")
                    }
                    else if let error = response.error
                    {
                        print("URLError occurred: \(error)")
                        self.hud?.textLabel.text = error.localizedDescription
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                    }
                    else
                    {
                        print("Unknown error: \(String(describing: response.error))")
                    }
                    
                    
                    
                    print("Web Service Title = " + self.serviceName!.url())
                    print("Web Service Status Code = \(String(describing: statusCode))")
                    print("Web Service Response String = \(response.value ?? "No Response Found")")
                    
                    
                    if((response.value) != nil)
                    {
                        let swiftyJsonVar = JSON(response.value!)
                        
                        if let jsonDict:Dictionary<String, Any> = swiftyJsonVar.dictionaryObject
                        {
                            //print("jsonDict = \(jsonDict)")
                            
                            let responseStatus:Int? = jsonDict[Constant.sucess] as? Int
                            let responseStatus1:Int? = jsonDict[Constant.success] as? Int
    //                        guard let status = responseStatus, let status1 = responseStatus1 else {
    //
    //                            fatalError("[WebServiceRequestError] Status cannot be nil")
    //
    //
    //                        }
                            
                            
                            if(responseStatus == 0 || responseStatus1 == 0)
                            {
                                self.hud!.textLabel.text = "error"
                                self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                                self.hud?.dismiss(afterDelay: 2, animated: true)
                                
                                return
                            }
                            
                            if let responseDic = jsonDict[Constant.return_data]{
                                self.delegateForWebServiceResponse?.webServiceDataParsingOnResponseReceived(url: self.serviceName,viewControllerObj: self.relatedViewController!,dataDict: responseDic,hud: self.hud!)
                            }
                            else{
                                self.delegateForWebServiceResponse?.webServiceDataParsingOnResponseReceived(url: self.serviceName,viewControllerObj: self.relatedViewController,dataDict: jsonDict,hud: self.hud!)
                            }
                            
                            
                        }
                    }
                    
            }
            
        }
    
    
    func callWebServiceWithFileUpload(imageData: Data?)
    {
        let serviceURL:String = self.serviceName!.url()
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in self.parameters!
            {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData
            {
                multipartFormData.append(data, withName: Constant.image, fileName: "image.png", mimeType: "image/png")
            }
            
        },to: serviceURL, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON { response in
            
            
            var statusCode:NSInteger? = nil
            if let responseObj: HTTPURLResponse = response.response
            {
                statusCode = responseObj.statusCode
            }
            
            if let error = response.error
            {
                statusCode = error._code // statusCode private
                switch error
                {
                case .invalidURL(let url):
                    print("Invalid URL: \(url) - \(error.localizedDescription)")
                    self.hud?.textLabel.text = "Invalid URL: \(url) - \(error.localizedDescription)"
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                    
                case .parameterEncodingFailed(let reason):
                    print("Parameter encoding failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    self.hud?.textLabel.text = "Failure Reason: \(reason)"
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                    
                case .multipartEncodingFailed(let reason):
                    print("Multipart encoding failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    self.hud?.textLabel.text = "Failure Reason: \(reason)"
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                    
                case .responseValidationFailed(let reason):
                    print("Response validation failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    self.hud?.textLabel.text = "Failure Reason: \(reason)"
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                    
                    switch reason
                    {
                    case .dataFileNil, .dataFileReadFailed:
                        print("Downloaded file could not be read")
                        self.hud?.textLabel.text = "Downloaded file could not be read"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        
                    case .missingContentType(let acceptableContentTypes):
                        print("Content Type Missing: \(acceptableContentTypes)")
                        
                        self.hud?.textLabel.text = "Content Type Missing: \(acceptableContentTypes)"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        
                    case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                        print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        
                        self.hud?.textLabel.text = "Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        
                        
                    case .unacceptableStatusCode(let code):
                        print("Response status code was unacceptable: \(code)")
                        statusCode = code
                        self.hud?.textLabel.text = "Response status code was unacceptable: \(code)"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                    default:
                        self.hud?.textLabel.text = error.localizedDescription
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                    }
                    
                case .responseSerializationFailed(let reason):
                    print("Response serialization failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    self.hud?.textLabel.text = error.localizedDescription
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                    // statusCode = 3840 ???? maybe..
                default:
                    print("Response serialization failed: \(error.localizedDescription)")
                    self.hud?.textLabel.text = error.localizedDescription
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                }
                
                print("Underlying error: \(String(describing: error.underlyingError))")
            }
            else if let error = response.error
            {
                print("URLError occurred: \(error)")
                self.hud?.textLabel.text = error.localizedDescription
                self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud?.dismiss(afterDelay: 2, animated: true)
            }
            else
            {
                print("Unknown error: \(String(describing: response.error))")
            }
            
            
            
            print("Web Service Title = " + self.serviceName!.url())
            print("Web Service Status Code = \(String(describing: statusCode))")
            print("Web Service Response String = \(response.value ?? "No Response Found")")
            
            
            if((response.value) != nil)
            {
                let swiftyJsonVar = JSON(response.value!)
                
                if let jsonDict:Dictionary<String, Any> = swiftyJsonVar.dictionaryObject
                {
                    //print("jsonDict = \(jsonDict)")
                    
                    let responseStatus:Int? = jsonDict[Constant.sucess] as? Int
                    let responseStatus1:Int? = jsonDict[Constant.success] as? Int
//                        guard let status = responseStatus, let status1 = responseStatus1 else {
//
//                            fatalError("[WebServiceRequestError] Status cannot be nil")
//
//
//                        }
                    
                    
                    if(responseStatus == 0 || responseStatus1 == 0)
                    {
                        self.hud!.textLabel.text = "error"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        
                        return
                    }
                    
                    if let responseDic = jsonDict[Constant.return_data]{
                        self.delegateForWebServiceResponse?.webServiceDataParsingOnResponseReceived(url: self.serviceName,viewControllerObj: self.relatedViewController!,dataDict: responseDic,hud: self.hud!)
                    }
                    else{
                        self.delegateForWebServiceResponse?.webServiceDataParsingOnResponseReceived(url: self.serviceName,viewControllerObj: self.relatedViewController,dataDict: jsonDict,hud: self.hud!)
                    }
                    
                    
                }
            }
            
    }
    }
    func callWebServiceWithFileUpload(imageData: Data?,val:String!)
    {
        let serviceURL:String! = self.serviceName!.url() + val
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in self.parameters!
            {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData
            {
                multipartFormData.append(data, withName: Constant.image, fileName: "image.png", mimeType: "image/png")
            }
            
        },to: serviceURL, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON { response in
            
            
            var statusCode:NSInteger? = nil
            if let responseObj: HTTPURLResponse = response.response
            {
                statusCode = responseObj.statusCode
            }
            
            if let error = response.error
            {
                statusCode = error._code // statusCode private
                switch error
                {
                case .invalidURL(let url):
                    print("Invalid URL: \(url) - \(error.localizedDescription)")
                    self.hud?.textLabel.text = "Invalid URL: \(url) - \(error.localizedDescription)"
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                    
                case .parameterEncodingFailed(let reason):
                    print("Parameter encoding failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    self.hud?.textLabel.text = "Failure Reason: \(reason)"
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                    
                case .multipartEncodingFailed(let reason):
                    print("Multipart encoding failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    self.hud?.textLabel.text = "Failure Reason: \(reason)"
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                    
                case .responseValidationFailed(let reason):
                    print("Response validation failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    self.hud?.textLabel.text = "Failure Reason: \(reason)"
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                    
                    switch reason
                    {
                    case .dataFileNil, .dataFileReadFailed:
                        print("Downloaded file could not be read")
                        self.hud?.textLabel.text = "Downloaded file could not be read"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        
                    case .missingContentType(let acceptableContentTypes):
                        print("Content Type Missing: \(acceptableContentTypes)")
                        
                        self.hud?.textLabel.text = "Content Type Missing: \(acceptableContentTypes)"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        
                    case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                        print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        
                        self.hud?.textLabel.text = "Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        
                        
                    case .unacceptableStatusCode(let code):
                        print("Response status code was unacceptable: \(code)")
                        statusCode = code
                        self.hud?.textLabel.text = "Response status code was unacceptable: \(code)"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                    default:
                        self.hud?.textLabel.text = error.localizedDescription
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                    }
                    
                case .responseSerializationFailed(let reason):
                    print("Response serialization failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    self.hud?.textLabel.text = error.localizedDescription
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                    // statusCode = 3840 ???? maybe..
                default:
                    print("Response serialization failed: \(error.localizedDescription)")
                    self.hud?.textLabel.text = error.localizedDescription
                    self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud?.dismiss(afterDelay: 2, animated: true)
                }
                
                print("Underlying error: \(String(describing: error.underlyingError))")
            }
            else if let error = response.error
            {
                print("URLError occurred: \(error)")
                self.hud?.textLabel.text = error.localizedDescription
                self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud?.dismiss(afterDelay: 2, animated: true)
            }
            else
            {
                print("Unknown error: \(String(describing: response.error))")
            }
            
            
            
            print("Web Service Title = " + self.serviceName!.url())
            print("Web Service Status Code = \(String(describing: statusCode))")
            print("Web Service Response String = \(response.value ?? "No Response Found")")
            
            
            if((response.value) != nil)
            {
                let swiftyJsonVar = JSON(response.value!)
                
                if let jsonDict:Dictionary<String, Any> = swiftyJsonVar.dictionaryObject
                {
                    //print("jsonDict = \(jsonDict)")
                    
                    let responseStatus:Int? = jsonDict[Constant.sucess] as? Int
                    let responseStatus1:Int? = jsonDict[Constant.success] as? Int
//                        guard let status = responseStatus, let status1 = responseStatus1 else {
//
//                            fatalError("[WebServiceRequestError] Status cannot be nil")
//
//
//                        }
                    
                    
                    if(responseStatus == 0 || responseStatus1 == 0)
                    {
                        self.hud!.textLabel.text = "error"
                        self.hud?.indicatorView = JGProgressHUDErrorIndicatorView()
                        self.hud?.dismiss(afterDelay: 2, animated: true)
                        
                        return
                    }
                    
                    if let responseDic = jsonDict[Constant.return_data]{
                        self.delegateForWebServiceResponse?.webServiceDataParsingOnResponseReceived(url: self.serviceName,viewControllerObj: self.relatedViewController!,dataDict: responseDic,hud: self.hud!)
                    }
                    else{
                        self.delegateForWebServiceResponse?.webServiceDataParsingOnResponseReceived(url: self.serviceName,viewControllerObj: self.relatedViewController,dataDict: jsonDict,hud: self.hud!)
                    }
                    
                    
                }
            }
            
    }

    }
    
}

