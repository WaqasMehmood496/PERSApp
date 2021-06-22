//
//  urlHelper.swift
//  PERS
//
//  Created by Buzzware Tech on 21/06/2021.
//

import UIKit
import AVKit

enum typeOfImage:String{
  case png = ".png"
  case jpg = ".jpg"
  case jpeg = ".jpeg"
}
enum imageFrom:String{
  case front = "front"
  case back = "back"
}
enum FileType: String{
  case none
  case imageFile = "ImageFile"
  case brustGifFile = "BrustGifFile"
  case videoFile = "VideoFile"
  case gifFile = "GifFile"
}
enum ImageExtention:String {
  case JPEG = "JPEG"
  case JPG = "JPG"
  case PNG = "PNG"
  case TIFF = "TIFF"
  case GIF = "GIF"
  case unknown = "unknown"
}
enum VideoExtention:String {
  case WEBM = "WEBM"
  case MPG = "MPG"
  case MP2 = "MP2"
  case MPEG = "MPEG"
  case MPE = "MPE"
  case MPV = "MPV"
  case OGG = "OGG"
  case MP4 = "MP4"
  case M4P = "M4P"
  case M4V = "M4V"
  case AVI = "AVI"
  case WMV = "WMV"
  case MOV = "MOV"
  case QT = "QT"
  case FLV = "FLV"
  case SWF = "SWF"
  case AVCHD = "AVCHD"
  case unknown = "unknown"
}

class MediaFile{
    
  var image:UIImage!
  var imageFilter:UIImage!
  var imageUrl:URL!
  var videoUrl:URL!
  var imageFilterUrl:URL!
  var videoFilterUrl:URL!
  var gifUrl:URL!
  var imageData: Data!
  var semanticSegmentationMatteDataArray:[Data]!
  var portraitEffectsMatteData: Data!
  var livePhotoCompanionMovieURL: URL!
  var fileName:String!
  init(image:UIImage? = nil,imageFilter:UIImage? = nil,imageUrl:URL? = nil,videoUrl:URL? = nil,imageFilterUrl:URL? = nil,videoFilterUrl:URL? = nil,gifUrl:URL? = nil,imageData:Data? = nil,semanticSegmentationMatteDataArray:[Data]? = nil,portraitEffectsMatteData:Data? = nil,livePhotoCompanionMovieURL:URL? = nil,fileName:String? = nil) {
    self.image = image
    self.imageFilter = imageFilter
    self.imageUrl = imageUrl
    self.videoUrl = videoUrl
    self.imageFilterUrl = imageFilterUrl
    self.videoFilterUrl = videoFilterUrl
    self.gifUrl = gifUrl
    self.imageData = imageData
    self.semanticSegmentationMatteDataArray = semanticSegmentationMatteDataArray
    self.portraitEffectsMatteData = portraitEffectsMatteData
    self.livePhotoCompanionMovieURL = livePhotoCompanionMovieURL
    self.fileName = fileName
  }
    
}


class UrlHelper: NSObject {

    static let shared = UrlHelper()
    func clearCachesDirectory(completion:@escaping((Bool) -> ())){
        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let fileManager = FileManager.default
            do {
                // Get the directory contents urls (including subfolders urls)
                let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: nil, options: [])
                for file in directoryContents {
                    do {
                        try fileManager.removeItem(at: file)
                        completion(true)
                    }
                    catch let error as NSError {
                        debugPrint("Ooops! Something went wrong: \(error)")
                        completion(false)
                    }

                }
            } catch let error as NSError {
                print(error.localizedDescription)
                completion(false)
            }
    }
    func saveImageDocumentDirectory(image: UIImage, completion:((_ image: UIImage,_ url: URL )->())? = nil){
        let fileManager = FileManager.default
        let getDate = Date().toMillis()
        //let formatter = DateFormatter()
        //formatter.dateFormat = "dd_MM_yyyy_hh_mm_ss"
        //let fdate = formatter.string(from: getDate)
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(getDate + ".png")
        //let image = UIImage(named: fdate + ".jpg")
        print(paths)
        let imageData = image.jpegData(compressionQuality: 0.0)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        let exportUrl: URL = NSURL.fileURL(withPath: paths as String)
        completion?(image,exportUrl)
        
        
    }
    func getDirectoryPath(_ fileType:FileType = .none) -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        var documentsDirectory = paths[0] as String
        if let displayname = Bundle.main.displayName{
            documentsDirectory = (paths[0] as NSString).appendingPathComponent(displayname) as String
        }
        let fileManager = FileManager.default
        switch fileType {
        case .none:
            
            if fileManager.fileExists(atPath: documentsDirectory){
                return documentsDirectory
            }
            else{
                do{
                    //let image = try fileManager.contentsOfDirectory(atPath: documentsDirectory)
                    try fileManager.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    return documentsDirectory
                }
                catch{
                    print(error)
                    return ""
                }
            }
            
        case .imageFile:
            documentsDirectory = (paths[0] as NSString).appendingPathComponent(fileType.rawValue) as String
            
            if fileManager.fileExists(atPath: documentsDirectory){
                return documentsDirectory
            }
            else{
                do{
                    //let image = try fileManager.contentsOfDirectory(atPath: documentsDirectory)
                    try fileManager.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    return documentsDirectory
                }
                catch{
                    print(error)
                    return ""
                }
            }
        case .videoFile:
            documentsDirectory = (paths[0] as NSString).appendingPathComponent(fileType.rawValue) as String
            
            if fileManager.fileExists(atPath: documentsDirectory){
                return documentsDirectory
            }
            else{
                do{
                    //let image = try fileManager.contentsOfDirectory(atPath: documentsDirectory)
                    try fileManager.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    return documentsDirectory
                }
                catch{
                    print(error)
                    return ""
                }
            }
        case .brustGifFile:
            documentsDirectory = (paths[0] as NSString).appendingPathComponent(fileType.rawValue) as String

            if fileManager.fileExists(atPath: documentsDirectory){
                return documentsDirectory
            }
            else{
                do{
                    //let image = try fileManager.contentsOfDirectory(atPath: documentsDirectory)
                    try fileManager.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    return documentsDirectory
                }
                catch{
                    print(error)
                    return ""
                }
            }
        case .gifFile:
            documentsDirectory = (paths[0] as NSString).appendingPathComponent(fileType.rawValue) as String

            if fileManager.fileExists(atPath: documentsDirectory){
                return documentsDirectory
            }
            else{
                do{
                    //let image = try fileManager.contentsOfDirectory(atPath: documentsDirectory)
                    try fileManager.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    return documentsDirectory
                }
                catch{
                    print(error)
                    return ""
                }
            }
        default:
            break
        }
        
    }
    
    func getCreateNewFile(mediaFile:MediaFile?,fileType:FileType? = nil, _ completion: ((MediaFile?)->())){
        
        var bool = false
        let fileManager = FileManager.default
        
        if let media = mediaFile{
            switch fileType {
            case .imageFile:
                if let filterurl = media.imageFilterUrl{
                    bool = fileManager.createFile(atPath: filterurl.path, contents: media.imageFilter.pngData(), attributes: nil)
                    if bool{
                        completion(media)
                    }
                    else{
                        completion(nil)
                    }
                }
                else{
                    if let data = media.imageData{
                        bool = fileManager.createFile(atPath: media.imageUrl.path, contents: data, attributes: nil)
                        if bool{
                            media.image = UIImage(data: media.imageData)
                            completion(media)
                        }
                        else{
                            completion(nil)
                        }
                    }
                    else if let image = media.imageFilter,let url = media.imageUrl{
                        let data = image.pngData()
                        bool = fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
                        if bool{
                            media.imageData = data
                            completion(media)
                        }
                        else{
                            completion(nil)
                        }
                    }
                    else{
                        if let image = media.image{
                            let data = image.pngData()
                            bool = fileManager.createFile(atPath: media.imageUrl.path, contents: data, attributes: nil)
                            if bool{
                                completion(media)
                            }
                            else{
                                completion(nil)
                            }
                        }
                        else{
                         completion(nil)
                        }
                        
                    }
                    
                }
            case .videoFile:
                do{
                    if let url = media.videoFilterUrl{
                        let data = try Data(contentsOf: media.videoUrl)
                        if fileManager.createFile(atPath: url.path, contents: data, attributes: nil){
                            try fileManager.removeItem(at: media.videoUrl)
                            completion(media)
                        }
                        else{
                            completion(nil)
                        }
                    }
                    else{
                        let data = try Data(contentsOf: media.videoUrl)
                        fileManager.createFile(atPath: media.videoUrl.path, contents: data, attributes: nil)
                        completion(media)
                    }
                    
                }
                catch let error{
                    print(error.localizedDescription)
                    completion(nil)
                }
            case .brustGifFile:
                bool = fileManager.createFile(atPath: media.imageUrl.path, contents: media.imageData, attributes: nil)
                if bool{
                    media.image = UIImage(data: media.imageData)
                    completion(media)
                }
                else{
                    completion(nil)
                }
            case .gifFile:
                if let url = media.videoUrl{
                    do{
                        let data = try Data(contentsOf: media.gifUrl)
                        var finalurl = url.deletingPathExtension()
                        finalurl.appendPathExtension(media.gifUrl.pathExtension)
                        fileManager.createFile(atPath: finalurl.path, contents: data, attributes: nil)
                        try fileManager.removeItem(at: media.gifUrl)
                        media.videoUrl = finalurl
                        completion(media)
                    }
                    catch let error{
                        print(error.localizedDescription)
                    }
                }
                else if let url = media.videoFilterUrl{
                    do{
                        let data = try Data(contentsOf: media.gifUrl)
                        var finalurl = url.deletingPathExtension()
                        finalurl.appendPathExtension(media.gifUrl.pathExtension)
                        fileManager.createFile(atPath: finalurl.path, contents: data, attributes: nil)
                        try fileManager.removeItem(at: media.gifUrl)
                        media.videoUrl = finalurl
                        completion(media)
                    }
                    catch let error{
                        print(error.localizedDescription)
                    }
                }
                
            default:
                completion(nil)
            }
        }
    }
    func getReplaceNewFile(fromUrl:URL? = nil,toUrl: URL? = nil, _ completion: ((Bool)->())? = nil){
        if let furl = fromUrl,let turl = toUrl{
            let fileManager = FileManager.default
            do{
               //var urls = try fileManager.replaceItemAt(turl, withItemAt: furl)
                //urls = try fileManager.replaceItemAt(furl, withItemAt: turl)
                //let data = try Data(contentsOf: furl)
                if fileManager.createFile(atPath: turl.path, contents:furl.dataRepresentation , attributes: nil){
                    try fileManager.removeItem(at: furl)
                    completion?(true)
                }
                else{
                    completion?(false)
                }
                
                
            }
            catch{
                print(error)
                completion?(false)
            }
            
            
            
        }
        else{
            completion?(false)
        }
    }
    func getMoveToFile(fromUrl:URL? = nil,toUrl: URL? = nil, _ completion: ((Bool,URL?)->())? = nil){
        if let furl = fromUrl,let turl = toUrl{
            let fileManager = FileManager.default
            do{
               //var urls = try fileManager.replaceItemAt(turl, withItemAt: furl)
                //urls = try fileManager.replaceItemAt(furl, withItemAt: turl)
                //let data = try Data(contentsOf: furl)
                
                try fileManager.moveItem(atPath: furl.path, toPath: turl.path)
                //try fileManager.removeItem(atPath: furl.path)
                    
                    completion?(true,turl)
                
            }
            catch{
                print(error)
                completion?(false,nil)
            }

        }
        else{
            completion?(false,nil)
        }
    }
    func getDuplicateFileUrl(mediaFile:MediaFile? = nil,fileType:FileType = .none, _ completion: ((MediaFile?)->())){
        
        let fdate = Date().toMillis()
        if let mediaFile = mediaFile{
            switch fileType {
            case .imageFile:
                let paths = ((self.getDirectoryPath(fileType) as NSString).appendingPathComponent(fdate) as NSString).appendingPathExtension(mediaFile.imageUrl.pathExtension)
                print(paths!)
                let exportUrl: URL = NSURL.fileURL(withPath: paths! as String)
                mediaFile.imageFilterUrl = exportUrl
                completion(mediaFile)
            case .videoFile:
                let paths = ((self.getDirectoryPath(fileType) as NSString).appendingPathComponent(fdate) as NSString).appendingPathExtension(mediaFile.videoUrl.pathExtension)
                print(paths!)
                let exportUrl: URL = NSURL.fileURL(withPath: paths! as String)
                mediaFile.videoFilterUrl = exportUrl
                completion(mediaFile)
            case .brustGifFile:
                let paths = (self.getDirectoryPath(fileType) as NSString).appendingPathComponent(fdate)
                print(paths)
                let exportUrl: URL = NSURL.fileURL(withPath: paths as String)
                mediaFile.livePhotoCompanionMovieURL = exportUrl
                completion(mediaFile)
            default:
                completion(nil)
            }
            
        }
        else{
            completion(nil)
        }
    }
    func getFileUrl(_ fileName:String? = nil,fileType: FileType = .none, _ completion: ((MediaFile?)->())){
        
        let fileManager = FileManager.default
        let media = MediaFile()
        if let fileName = fileName{
            do{
                let directoryPAth = (getDirectoryPath(fileType) as NSString).appendingPathComponent(fileName)
                if fileManager.fileExists(atPath: directoryPAth){
                    let exportUrl: URL = NSURL.fileURL(withPath: directoryPAth as String)
                    let data = try Data(contentsOf: exportUrl)
                    media.imageUrl = exportUrl
                    media.imageData = data
                    completion(media)
                }
                else{
                    completion(nil)
                }
            }
            catch let error{
                print(error.localizedDescription)
                completion(nil)
            }
            
        }
        else{
            completion(nil)
        }
    }
    func getNewDocumentUrls(fileName:String? = nil,fileType: FileType = .none, _ completion: ((_ fileName: String? ,_ filePath: String?)->())? = nil){
        if let name = fileName{
            if name.contains(".csv"){
                let fileManager = FileManager.default
                let directoryPAth = (getDirectoryPath(fileType) as NSString).appendingPathComponent(name)
                if fileManager.fileExists(atPath: directoryPAth){
                    completion?(name,directoryPAth)
                }
                else{
                    completion?(name,directoryPAth)
                }
            }
            else{
                if fileName == ""{
                    let fdate = Date().toMillis()
                    let paths = (getDirectoryPath(fileType) as NSString).appendingPathComponent(fdate + ".csv")
                        print(paths)
                        //let exportUrl: URL = NSURL.fileURL(withPath: paths as String)
                        completion?(fdate,paths)
                }
                else{
                    let finalName = name + ".csv"
                    let fileManager = FileManager.default
                    let directoryPAth = (getDirectoryPath(fileType) as NSString).appendingPathComponent(finalName)
                    if fileManager.fileExists(atPath: directoryPAth){
                        completion?(finalName,directoryPAth)
                    }
                    else{
                        completion?(finalName,directoryPAth)
                    }
                }
                
            }
            
            
        }
        else{
            
                    let fdate = Date().toMillis()
                    let paths = (getDirectoryPath(fileType) as NSString).appendingPathComponent(fdate + ".csv")
                        print(paths)
                        completion?(fdate,paths)
        }
        
    }
    func getNewDocumentUrl(url: URL? = nil, fileType: FileType = .imageFile, _ completion: ((MediaFile?)->())? = nil){
        let fdate = Date().toMillis()
        if let urlstr = url{
            let paths = ((self.getDirectoryPath(fileType) as NSString).appendingPathComponent(fdate) as NSString).appendingPathExtension(urlstr.pathExtension)
            print(paths)
            do{
                let data = try Data(contentsOf: urlstr)
                FileManager.default.createFile(atPath: paths!, contents: data, attributes: nil)
                
                let exportUrl: URL = NSURL.fileURL(withPath: paths! as String)
                switch fileType {
                case .imageFile:
                    let image = UIImage(data: data)
                    let mediaFile = MediaFile(image: image, imageUrl: exportUrl)
                    completion?(mediaFile)
                    
                case .videoFile:
                    let mediaFile = MediaFile(videoUrl: exportUrl)
                    completion?(mediaFile)
                case .brustGifFile:
                    let mediaFile = MediaFile(gifUrl: exportUrl)
                    completion?(mediaFile)
                case .gifFile:
                    let mediaFile = MediaFile(gifUrl: exportUrl)
                    completion?(mediaFile)
                default:
                    completion?(nil)
                }
                
            }
            catch{
                completion?(nil)
                
            }
        }
        else{
            switch fileType {
            case .imageFile:
                let paths = (self.getDirectoryPath(fileType) as NSString).appendingPathComponent(fdate)
                print(paths)
                let exportUrl: URL = NSURL.fileURL(withPath: paths as String).appendingPathExtension(ImageExtention.JPEG.rawValue.lowercased())
                let mediaFile = MediaFile(imageUrl: exportUrl)
                completion?(mediaFile)
            case .videoFile:
                let paths = (self.getDirectoryPath(fileType) as NSString).appendingPathComponent(fdate)
                print(paths)
                let exportUrl: URL = NSURL.fileURL(withPath: paths as String).appendingPathExtension(VideoExtention.MOV.rawValue.lowercased())
                let mediaFile = MediaFile(videoUrl: exportUrl)
                completion?(mediaFile)
            case .brustGifFile:
                let paths = (self.getDirectoryPath(fileType) as NSString).appendingPathComponent(fdate)
                print(paths)
                let exportUrl: URL = NSURL.fileURL(withPath: paths as String).appendingPathExtension(ImageExtention.GIF.rawValue.lowercased())
                let mediaFile = MediaFile(gifUrl: exportUrl)
                completion?(mediaFile)
            case .gifFile:
                let paths = (self.getDirectoryPath(fileType) as NSString).appendingPathComponent(fdate)
                print(paths)
                let exportUrl: URL = NSURL.fileURL(withPath: paths as String).appendingPathExtension(ImageExtention.GIF.rawValue.lowercased())
                let mediaFile = MediaFile(gifUrl: exportUrl)
                completion?(mediaFile)
            default:
                completion?(nil)
            }
        }
    }
    func getNewDocumentUrlFromDownload(mediaFile: MediaFile? , fileType: FileType = .imageFile, _ completion: ((MediaFile?)->())? = nil){
        if let media = mediaFile{
            let paths = (self.getDirectoryPath(fileType) as NSString).appendingPathComponent(media.fileName)
            print(paths)
            let exportUrl: URL = NSURL.fileURL(withPath: paths as String)
            if !FileManager.default.fileExists(atPath: paths){
                if FileManager.default.createFile(atPath: paths, contents: media.imageData, attributes: nil){
                    media.imageUrl = exportUrl
                    completion?(media)
                }
                else{
                    completion?(nil)
                }
            }
            else{
                completion?(nil)
            }
            
        }
        
    }
    func getUrlToImage(mediaFile: MediaFile?,completion:@escaping((MediaFile?)->Void)){
        let fileManger = FileManager.default
        if let media = mediaFile{
            if let url = media.imageUrl{
                if fileManger.fileExists(atPath: url.path){
                    do{
                        let data = try Data(contentsOf: url)
                        media.image = UIImage(data: data)
                        media.imageData = data
                        completion(media)
                    }
                    catch let error{
                        print(error.localizedDescription)
                        completion(nil)
                    }
                }
                else{
                    completion(nil)
                }
            }
            else{
                completion(nil)
            }
        }
        else{
            completion(nil)
        }
    }
    func getThumbnailImageFromVideoUrl(mediaFile: MediaFile, completion: @escaping ((MediaFile)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: mediaFile.videoUrl) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                mediaFile.image = thumbImage
                DispatchQueue.main.async { //8
                    
                    completion(mediaFile) //9
                }
            } catch {
                print(error.localizedDescription) //10
                debugPrint(error)
                do{
                    let fileManger = FileManager.default
                    if fileManger.isReadableFile(atPath: mediaFile.videoUrl.path){
                        completion(mediaFile)
                    }
                    else{
                        try fileManger.removeItem(at: mediaFile.videoUrl)
                        DispatchQueue.main.async {
                            debugPrint("Removed")
                            completion(mediaFile) //11
                        }
                    }
                    
                }
                catch{
                    debugPrint(error)
                }
                
                
            }
        }
    }
    func deleteDocumentDirectory(url:URL? = nil,mediaFile: MediaFile? = nil,fileType: FileType = .none, _ completion: ((MediaFile?,Bool?)->())? = nil) {
        
        let fileManager = FileManager.default
        switch fileType {
        case .imageFile:
            if let furl = mediaFile?.imageUrl{
                
                let imagePath = (self.getDirectoryPath(fileType) as NSString).appendingPathComponent(furl.lastPathComponent)
                if fileManager.fileExists(atPath: imagePath){
                    do{
                        try fileManager.removeItem(atPath: imagePath)
                        print("deleted")
                        mediaFile?.imageUrl = nil
                        mediaFile?.image = nil
                        completion?(mediaFile,true)
                    }
                    catch let error{
                        print(error.localizedDescription)
                        completion?(nil,false)
                    }
                    
                    
                }
                else{
                    completion?(nil,false)
                }
            }
        case .videoFile:
            if let furl = mediaFile?.videoUrl{
                
                let imagePath = (self.getDirectoryPath(fileType) as NSString).appendingPathComponent(furl.lastPathComponent)
                if fileManager.fileExists(atPath: imagePath){
                    do{
                        try fileManager.removeItem(atPath: imagePath)
                        print("deleted")
                        mediaFile?.videoUrl = nil
                        mediaFile?.image = nil
                        completion?(mediaFile,true)
                    }
                    catch let error{
                        print(error.localizedDescription)
                        completion?(nil,false)
                    }
                    
                    
                }
                else{
                    completion?(nil,false)
                }
            }
            else if let furl = mediaFile?.videoFilterUrl{
                
                let imagePath = (self.getDirectoryPath(fileType) as NSString).appendingPathComponent(furl.lastPathComponent)
                if fileManager.fileExists(atPath: imagePath){
                    do{
                        try fileManager.removeItem(atPath: imagePath)
                        print("deleted")
                        mediaFile?.videoFilterUrl = nil
                        mediaFile?.image = nil
                        completion?(mediaFile,true)
                    }
                    catch let error{
                        print(error.localizedDescription)
                        completion?(nil,false)
                    }
                    
                    
                }
                else{
                    completion?(nil,false)
                }
            }
            else{
                completion?(nil,false)
            }
        case .gifFile:
            if let furl = mediaFile?.videoUrl{
                
                let imagePath = (self.getDirectoryPath(fileType) as NSString).appendingPathComponent(furl.lastPathComponent)
                if fileManager.fileExists(atPath: imagePath){
                    do{
                        try fileManager.removeItem(atPath: imagePath)
                        print("deleted")
                        mediaFile?.videoUrl = nil
                        mediaFile?.image = nil
                        completion?(mediaFile,true)
                    }
                    catch let error{
                        print(error.localizedDescription)
                        completion?(nil,false)
                    }
                    
                    
                }
                else{
                    completion?(nil,false)
                }
            }
            else{
                completion?(nil,false)
            }
        case .brustGifFile:
            if let iurl = mediaFile?.imageUrl,let vurl = mediaFile?.videoUrl{
                
                let imagePath = (self.getDirectoryPath(fileType) as NSString).appendingPathComponent(iurl.lastPathComponent)
                let videoPath = (self.getDirectoryPath(fileType) as NSString).appendingPathComponent(vurl.lastPathComponent)
                if fileManager.fileExists(atPath: imagePath) && fileManager.fileExists(atPath: videoPath){
                    do{
                        try fileManager.removeItem(atPath: imagePath)
                        try fileManager.removeItem(atPath: videoPath)
                        print("deleted")
                        mediaFile?.imageUrl = nil
                        mediaFile?.videoUrl = nil
                        mediaFile?.image = nil
                        completion?(mediaFile,true)
                    }
                    catch let error{
                        print(error.localizedDescription)
                        completion?(nil,false)
                    }
                    
                    
                }
                else{
                    completion?(nil,false)
                }
            }
        default:
            if let urls = url{
                
                if fileManager.fileExists(atPath: urls.path){
                    do{
                        try fileManager.removeItem(atPath: urls.path)
                        print("deleted")
                        completion?(nil,true)
                    }
                    catch let error{
                        print(error.localizedDescription)
                        completion?(nil,false)
                    }
                }
                else{
                    completion?(nil,false)
                }
            }
            else{
                completion?(nil,false)
            }
        }
    }
}
