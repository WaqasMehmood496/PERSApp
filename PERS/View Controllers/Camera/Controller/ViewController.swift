//
//  ViewController.swift
//  Tinytype
//
//  Created by Dr. Atta on 08/01/2019.
//  Copyright © 2019 ebmacs. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
var goView : Bool! = true
class ViewController: UIViewController {
	let cameraController = CameraController()
	
//	var session: AVCaptureSession?
//	var stillImageOutput: AVCaptureStillImageOutput?
//	var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	
	var imagePicker = UIImagePickerController()
	var selectedImage: UIImage!
	
	static var flashOn : Bool!
    static var blackwhite : Bool!
    static var borderless : Bool!
    static var invert : Bool!
    static var gridVisible = true
	
	
	@IBOutlet weak var photoPreviewImageView: UIImageView!
	@IBOutlet weak var CameraPreviewImageView: UIImageView!
	@IBOutlet weak var gridView: UIImageView!
	
	@IBOutlet weak var flashBtn: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		cameraController.flashMode = .off
		self.flashBtn.isHighlighted = true

		imagePicker.delegate = self
		ViewController.flashOn = false
        ViewController.blackwhite = false
        ViewController.borderless = true
        ViewController.invert = false
		toggleFlash()
	self.navigationController?.setNavigationBarHidden(true, animated: false)
		
		selectedImage = UIImage(named: "video-btn")
		//			setupCamera()
		
		func configureCameraController() {
			cameraController.prepare {(error) in
				if let error = error {
					print(error)
				}
				
				try? self.cameraController.displayPreview(on: self.photoPreviewImageView)
			}
		}
		
		configureCameraController()
		self.toggleGrid()
	}
	
	
	func toggleGrid(){
		if (ViewController.gridVisible==true){
			gridView.alpha = 1.0
		}else{
			gridView.alpha = 0.0
		}
		if(ViewController.flashOn){
			cameraController.flashMode = .on
		}
		else{
			cameraController.flashMode = .off
		}
	}
	func toggleFlash(){
		if(ViewController.flashOn){
			cameraController.flashMode = .on
		}
		else{
			cameraController.flashMode = .off
		}
		print(ViewController.flashOn)
	}
	
	@IBAction func capture(_ sender: UIButton) {
        
        //let imageshow  = UIImageView(image: UIImage(named: "flash_frame"))
        //imageshow.frame = CGRect(x: CameraPreviewImageView.frame.origin.x + 25, y: CameraPreviewImageView.frame.origin.y + 40, width: CameraPreviewImageView.frame.width - 50, height: CameraPreviewImageView.frame.height - 80)
        //self.CameraPreviewImageView.image = nil
         let flashView = UIView(frame: self.CameraPreviewImageView.frame)
        
        flashView.backgroundColor = UIColor.init(red: 39.0/255.0, green: 37.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        flashView.frame = self.CameraPreviewImageView.bounds
        flashView.alpha = 1
        
       
        //self.view.addSubview(imageshow)
        var soundid : SystemSoundID!
        soundid = 0
        if (soundid == 0)
        {
            let path = "/System/Library/Audio/UISounds/photoShutter.caf"
            let url = URL(fileURLWithPath: path, isDirectory: true)
            AudioServicesCreateSystemSoundID(url as CFURL, &soundid)
            AudioServicesPlaySystemSound(soundid)
        }
		cameraController.captureImage {(image, error) in
			guard let image = image else {
				print(error ?? "Image capture error")
				return
			}
            self.photoPreviewImageView.addSubview(flashView)
			try? PHPhotoLibrary.shared().performChangesAndWait {
				PHAssetChangeRequest.creationRequestForAsset(from: image)
                
                self.selectedImage = image
                UIView.animate(withDuration: 0.1, delay: 0, options: .autoreverse, animations: {
                    flashView.alpha = 0
                    self.photoPreviewImageView.willRemoveSubview(flashView)
                }, completion: nil)
//                UIView.animate(withDuration: 0.1, delay: 0, options: .autoreverse, animations: {
//                    flashView.alpha = 0
//                }, completion: nil)
                
			}
            
            //self.view.willRemoveSubview(imageshow)
            //self.CameraPreviewImageView.image = UIImage(named: "preview-frame")
            
		}
        
//		print("Capture pressed")
	}
	


	@IBAction func switchCameras(_ sender: UIButton) {
		do {
			try cameraController.switchCameras()
		}
			
		catch {
			print(error)
		}
		
	}
	
	@IBAction func setFlash(_ sender: UIButton) {
//		flashOn = !flashOn
//		if(flashOn){
//			sender.setImage(UIImage(named: "flash-btn-on"), for: .selected)
//			sender.isSelected = true
//		}
//		else{
//			sender.isSelected = false
//		}
		if cameraController.flashMode == .off {
			cameraController.flashMode = .on
			sender.isHighlighted = false
		}
		else if cameraController.flashMode == .on{
			cameraController.flashMode = .off
			sender.isHighlighted = true
		}
	}
	
	@IBAction func showSavedImages(_ sender: UIButton) {
        //self.performSegue(withIdentifier: "toLabImageView", sender: nil)
        //imagePicker.sourceType = .savedPhotosAlbum
        //imagePicker.allowsEditing = false
        //self.present(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func selectImagetoEdit(_ sender: Any) {

			imagePicker.sourceType = .photoLibrary
			imagePicker.allowsEditing = true
			
			self.present(imagePicker, animated: true, completion: nil)
		
	}
    

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

		
		if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            //pickedImage = resizeImage(image: pickedImage, newWidth: 1080)!
			self.selectedImage = resizeImage(image: pickedImage)
            //saveImageDocumentDirectory(image: self.selectedImage)
			self.performSegue(withIdentifier: "toImageEditView", sender: nil)
		}
		
		/*
		
		Swift Dictionary named “info”.
		We have to unpack it from there with a key asking for what media information we want.
		We just want the image, so that is what we ask for.  For reference, the available options are:
		
		UIImagePickerControllerMediaType
		UIImagePickerControllerOriginalImage
		UIImagePickerControllerEditedImage
		UIImagePickerControllerCropRect
		UIImagePickerControllerMediaURL
		UIImagePickerControllerReferenceURL
		UIImagePickerControllerMediaMetadata
		
		*/
		dismiss(animated: true, completion: nil)
	}
	
    override func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion:nil)
		
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		if let nextController = segue.destination as? imageEditViewController{
//            ViewController.blackwhite = false
//            ViewController.borderless = true
//            ViewController.invert = false
//			nextController.selectedImage = self.selectedImage
//		}
//        else{
//            goView = true
//        }
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
		self.toggleGrid()
		self.toggleFlash()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
}

extension PHPhotoLibrary {
	// MARK: - PHPhotoLibrary+SaveImage
	
	// MARK: - Public
	
	func savePhoto(image:UIImage, albumName:String, completion:((PHAsset?)->())? = nil) {
		func save() {
			if let album = PHPhotoLibrary.shared().findAlbum(albumName: albumName) {
				PHPhotoLibrary.shared().saveImage(image: image, album: album, completion: completion)
			} else {
				PHPhotoLibrary.shared().createAlbum(albumName: albumName, completion: { (collection) in
					if let collection = collection {
						PHPhotoLibrary.shared().saveImage(image: image, album: collection, completion: completion)
					} else {
						completion?(nil)
					}
				})
			}
		}
		
		if PHPhotoLibrary.authorizationStatus() == .authorized {
			save()
		} else {
			PHPhotoLibrary.requestAuthorization({ (status) in
				if status == .authorized {
					save()
				}
			})
		}
	}
	
	// MARK: - Private
	
	fileprivate func findAlbum(albumName: String) -> PHAssetCollection? {
		let fetchOptions = PHFetchOptions()
		fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
		let fetchResult : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
		guard let photoAlbum = fetchResult.firstObject else {
			return nil
		}
		return photoAlbum
	}
	
	fileprivate func createAlbum(albumName: String, completion: @escaping (PHAssetCollection?)->()) {
		var albumPlaceholder: PHObjectPlaceholder?
		PHPhotoLibrary.shared().performChanges({
			let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
			albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
		}, completionHandler: { success, error in
			if success {
				guard let placeholder = albumPlaceholder else {
					completion(nil)
					return
				}
				let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
				guard let album = fetchResult.firstObject else {
					completion(nil)
					return
				}
				completion(album)
			} else {
				completion(nil)
			}
		})
	}
	
	fileprivate func saveImage(image: UIImage, album: PHAssetCollection, completion:((PHAsset?)->())? = nil) {
		var placeholder: PHObjectPlaceholder?
		PHPhotoLibrary.shared().performChanges({
			let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
			guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
				let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else { return }
			placeholder = photoPlaceholder
			let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
			albumChangeRequest.addAssets(fastEnumeration)
		}, completionHandler: { success, error in
			guard let placeholder = placeholder else {
				completion?(nil)
				return
			}
			if success {
				let assets:PHFetchResult<PHAsset> =  PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
				let asset:PHAsset? = assets.firstObject
				completion?(asset)
			} else {
				completion?(nil)
			}
		})
	}
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
extension UIViewController{
    func resizeImage(image: UIImage ) -> UIImage {
        
        //let scale = 1350 / image.size.height
        //let newWidth = image.size.width * scale
        let newSize = CGSize(width: 1080, height: 1350)
        UIGraphicsBeginImageContext(CGSize(width: newSize.width, height: newSize.height))
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func saveImageDocumentDirectory(image: UIImage){
        let fileManager = FileManager.default
        let getDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd_MM_yyyy_hh_mm_ss"
        let fdate = formatter.string(from: getDate)
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fdate + ".jpg")
        //let image = UIImage(named: fdate + ".jpg")
        print(paths)
        let imageData = image.jpegData(compressionQuality: 0.0)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        
        
    }
//    func saveImageDocumentDirectory(image: UIImage){
//        let fileManager = FileManager.default
//        let getDate = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd_MM_yyyy_hh_mm_ss"
//        let fdate = formatter.string(from: getDate)
//        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fdate + ".jpg")
//        //let image = UIImage(named: fdate + ".jpg")
//        print(paths)
//        let imageData = image.jpegData(compressionQuality: 0.0)
//        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
//        
//        
//    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        return documentsDirectory
    }
//    func getDirectoryPath() -> String {
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let documentsDirectory = paths[0] as String
//        
//        return documentsDirectory
//    }
}
