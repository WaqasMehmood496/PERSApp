//
//  CameraController.swift
//  Tinytype
//
//  Created by Dr. Atta on 12/01/2019.
//  Copyright © 2019 ebmacs. All rights reserved.
//

import UIKit
import Photos

class CameraController:NSObject {
	var captureSession: AVCaptureSession?
	
	var currentCameraPosition: CameraPosition?
	
	var frontCamera: AVCaptureDevice?
	var frontCameraInput: AVCaptureDeviceInput?
	
	var photoOutput: AVCapturePhotoOutput?
	
	var rearCamera: AVCaptureDevice?
	var rearCameraInput: AVCaptureDeviceInput?
	
	var previewLayer: AVCaptureVideoPreviewLayer?
	var flashMode = AVCaptureDevice.FlashMode.off
	
	var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
}

extension CameraController {

	func displayPreview(on view: UIView) throws {
		guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
		
		self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		self.previewLayer?.connection?.videoOrientation = .portrait
		
		view.layer.insertSublayer(self.previewLayer!, at: 0)
		self.previewLayer?.frame = view.frame
		//		self.previewLayer?.frame.origin = view.frame.origin
	}
	
	func prepare(completionHandler: @escaping (Error?) -> Void) {
		func createCaptureSession() {
			self.captureSession = AVCaptureSession()
		}
		
		func configureCaptureDevices() throws {
			let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
			
			
			let cameras = (session.devices.compactMap{ $0 })
			
			if cameras == nil {
				print("Camera unable to set up")
				return
			}
			
			for camera in cameras {
				if camera.position == .front {
					self.frontCamera = camera
				}
				
				if camera.position == .back {
					self.rearCamera = camera
					
					try camera.lockForConfiguration()
					camera.focusMode = .continuousAutoFocus
                    
					camera.unlockForConfiguration()
                    
				}
			}
		}
		
		func configureDeviceInputs() throws {
			guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
			
			if let rearCamera = self.rearCamera {
				self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
				
				if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
				
				self.currentCameraPosition = .rear
			}
				
			else if let frontCamera = self.frontCamera {
				self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
				
				if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
				else { throw CameraControllerError.inputsAreInvalid }
				
				self.currentCameraPosition = .front
			}
				
			else { throw CameraControllerError.noCamerasAvailable }
		}
		
		func configurePhotoOutput() throws {
			guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
			
			self.photoOutput = AVCapturePhotoOutput()
			self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
			
			if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            captureSession
			captureSession.startRunning()
		}
		
		DispatchQueue(label: "prepare").async {
			do {
				createCaptureSession()
				try configureCaptureDevices()
				try configureDeviceInputs()
				try configurePhotoOutput()
			}
				
			catch {
				DispatchQueue.main.async {
					completionHandler(error)
				}
				
				return
			}
			
			DispatchQueue.main.async {
				completionHandler(nil)
			}
		}
	}
}

extension CameraController {
	enum CameraControllerError: Swift.Error {
		case captureSessionAlreadyRunning
		case captureSessionIsMissing
		case inputsAreInvalid
		case invalidOperation
		case noCamerasAvailable
		case unknown
	}
	
	public enum CameraPosition {
		case front
		case rear
	}
	
	func switchCameras() throws {
		guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
		
		captureSession.beginConfiguration()
		
		func switchToFrontCamera() throws {
			guard let inputs = captureSession.inputs as? [AVCaptureInput], let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
				let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
			
			self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
			
			captureSession.removeInput(rearCameraInput)
			
			if (captureSession.canAddInput(self.frontCameraInput!)){
				captureSession.addInput(self.frontCameraInput!)
				
				self.currentCameraPosition = .front
			}
				
			else { throw CameraControllerError.invalidOperation }
		}
		
		func switchToRearCamera() throws {
			guard let inputs = captureSession.inputs as? [AVCaptureInput], let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
				let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
			
			self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
			
			captureSession.removeInput(frontCameraInput)
			
			if captureSession.canAddInput(self.rearCameraInput!) {
				captureSession.addInput(self.rearCameraInput!)
				
				self.currentCameraPosition = .rear
			}
				
			else { throw CameraControllerError.invalidOperation }
		}
		
		
		switch currentCameraPosition {
		case .front:
			try switchToRearCamera()
			
		case .rear:
			try switchToFrontCamera()
		}
		
		captureSession.commitConfiguration()
	}
	
	
	func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
		guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
		
		let settings = AVCapturePhotoSettings()
		settings.flashMode = self.flashMode
        settings.isAutoStillImageStabilizationEnabled = true
		
		self.photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
		self.photoCaptureCompletionBlock = completion
	}

	
}

extension CameraController: AVCapturePhotoCaptureDelegate {
	public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
							resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {
		if let error = error { self.photoCaptureCompletionBlock!(nil, error) }
			
		else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
			let image = UIImage(data: data) {
			
			self.photoCaptureCompletionBlock!(image, nil)
            
            self.saveImageDocumentDirectory(image: resizeImage(image: image))
            
		}
			
		else {
			self.photoCaptureCompletionBlock!(nil, CameraControllerError.unknown)
		}
	}
	
    func resizeImage(image: UIImage ) -> UIImage {
        
        
//        let newScale = image.scale // change this if you want the output image to have a different scale
//        let originalSize = image.size
//        let targetSize = CGSize(width: 1080, height: 1350)
//        let widthRatio = targetSize.width / originalSize.width
//        let heightRatio = targetSize.height / originalSize.height
//
//        // Figure out what our orientation is, and use that to form the rectangle
//        let newSize: CGSize
//        if widthRatio > heightRatio {
//            newSize = CGSize(width: floor(originalSize.width * heightRatio), height: floor(originalSize.height * heightRatio))
//        } else {
//            newSize = CGSize(width: floor(originalSize.width * widthRatio), height: floor(originalSize.height * widthRatio))
//        }
//
//        // This is the rect that we've calculated out and this is what is actually used below
//        let rect = CGRect(origin: .zero, size: newSize)
//
//        // Actually do the resizing to the rect using the ImageContext stuff
//        let format = UIGraphicsImageRendererFormat()
//        format.scale = newScale
//        format.opaque = true
//        let newImage = UIGraphicsImageRenderer(bounds: rect, format: format).image() { _ in
//            image.draw(in: rect)
//        }
//
//        return newImage
        let newSize = CGSize(width: 1080, height: 1350)
        let scale = newSize.width / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newSize.width, height: newHeight))

        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
//        UIGraphicsBeginImageContextWithOptions(cropRect.size, false, 0);
//        let context = UIGraphicsGetCurrentContext();
//
//        context?.translateBy(x: 0.0, y: image.size.height);
//        context?.scaleBy(x: 1.0, y: -1.0);
//        context?.draw(image.cgImage!, in: CGRect(x:0, y:0, width:image.size.width, height:image.size.height), byTiling: false);
//        context?.clip(to: [cropRect]);
//
//        let croppedImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//
//        return croppedImage!;
//        return newImage!
        let cgimage = newImage?.cgImage!
        //let contextImage: UIImage = UIImage(cgImage: cgimage)
        //let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        //var cgwidth: CGFloat = CGFloat(width)
        //var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        //if contextSize.width > contextSize.height {
        posX = (((newImage?.size.width)! - newSize.width) / 2)
        posY = (((newImage?.size.height)! - newSize.height) / 2)
//            cgwidth = contextSize.height
//            cgheight = contextSize.height
        //} else {
//            posX = 0
//            posY = ((contextSize.height - contextSize.width) / 2)
//            cgwidth = contextSize.width
//            cgheight = contextSize.width
        //}
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: newSize.width, height: newSize.height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let finalImage: UIImage = UIImage(cgImage: imageRef, scale: newImage!.scale, orientation: newImage!.imageOrientation)
        
        return finalImage
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
}
