//
//  SignUpViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 10/06/2021.
//

import UIKit
import JGProgressHUD
import Firebase

class SignUpViewController: UIViewController, PassDataDelegate {
    
    //MARK: IBOUTLET'S
    @IBOutlet weak var FullNameTF: UITextField!
    @IBOutlet weak var EmailTF: UITextField!
    @IBOutlet weak var MobileNumberTF: UITextField!
    @IBOutlet weak var LocationTF: UITextField!
    @IBOutlet weak var PasswordTF: UITextField!
    @IBOutlet weak var RegisterButton: UIButton!
    
    //MARK: VARIABLE'S
    var ref: DatabaseReference!
    var mAuth = Auth.auth()
    var userLocation = LocationModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.setupUI()
    }
    
    //MARK: IBACTION'S
    @IBAction func ResisterButtonAction(_ sender: Any) {
        self.SignUpUser()
    }
}

//MARK:- HELPING FUNCTION'S EXTENSION
extension SignUpViewController{
    
    // SETUP USER INTERFACE WITH SOME MODIFICATION
    func setupUI() {
        self.setupLeftPaddingOnTextFields()
        self.setupRightPaddingOnTextFields()
        self.buttonCustomization()
        self.addTabGuestureOnLocationTextField()
    }
    
    //ADD LEFT PADDING ON ALL TEXTFIELD'S
    func setupLeftPaddingOnTextFields() {
        FullNameTF.setLeftPaddingPoints(8)
        EmailTF.setLeftPaddingPoints(8)
        MobileNumberTF.setLeftPaddingPoints(8)
        LocationTF.setLeftPaddingPoints(8)
        PasswordTF.setLeftPaddingPoints(8)
    }
    
    //ADD RIGHT PADDING ON ALL TEXTFIELD'S
    func setupRightPaddingOnTextFields() {
        FullNameTF.setRightPaddingPoints(8)
        EmailTF.setRightPaddingPoints(8)
        MobileNumberTF.setRightPaddingPoints(8)
        LocationTF.setRightPaddingPoints(8)
        PasswordTF.setRightPaddingPoints(8)
    }
    
    //ADD GRADIENT ON BUTTON
    func buttonCustomization() {
        guard let darkColor = UIColor(named: "Gradient Dark Color")?.cgColor else{return}
        guard let lightColor = UIColor(named: "Gradient Light Color")?.cgColor else{return}
        RegisterButton.setGradient(colors: [darkColor,lightColor])
        RegisterButton.clipsToBounds = true
    }
    
    //ADD TAP GUESTURE ON LOCATION TEXTFIELD FOR GETTING USER CURRENT LOCATION
    func addTabGuestureOnLocationTextField() {
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(LocationTextFieldSelector(_:)))
        self.LocationTF.addGestureRecognizer(tapGuesture)
    }
    
    @objc func LocationTextFieldSelector(_ sender: UITextField){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mapController = storyboard.instantiateViewController(identifier: "MapsViewController") as! MapsViewController
        mapController.delagate = self
        self.present(mapController, animated: true, completion: nil)
    }
    
    // DELEGTE METHOD WHICH RETURN USER CURRENT LOCATION
    func passCurrentLocation(data: LocationModel) {
        self.userLocation = data
        self.LocationTF.text = data.address
    }
    
    // ERROR ALERT POPUP WITH ERROR MESSAGE
    func ErrorAlertMessage(title:String,description:String) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                alert.dismiss(animated: true, completion: nil)
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            @unknown default:
                break
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK:- FIREBASE METHOD'S EXTENSION
extension SignUpViewController{
    
    // VALIDATE USER AND INSERT INTO FIREBASE
    func SignUpUser(){
        let fullname = FullNameTF.text!
        let email = EmailTF.text!
        let mobilenumber = MobileNumberTF.text!
        let location = LocationTF.text!
        let password = PasswordTF.text!
        if Connectivity.isConnectedToNetwork(){
            showHUDView(hudIV: .indeterminate, text: .process) { (hud) in
                hud.show(in: self.view, animated: true)
                if fullname != "" && email != "" && mobilenumber != "" && location != "" && password != ""
                {
                    self.mAuth.createUser(withEmail: email, password: password) { result, err in
                        if let error = err {
                            print(error)
                            hud.dismiss()
                            PopupHelper.alertWithOk(title: "Alert", message: error.localizedDescription, controler: self)
                        }
                        else{
                            self.mAuth.currentUser?.sendEmailVerification(completion: { err in
                                if let error = err{
                                    print(error)
                                    hud.dismiss()
                                    self.ErrorAlertMessage(title: "Alert", description: error.localizedDescription)
                                    
                                }
                                else{
                                    self.insertUserIntoDataBase(fullname: fullname, email: email, mobileNumber: mobilenumber, location: location, password: password)
                                    hud.dismiss()
                                    
                                }
                            })//End send Email verification
                        }// End Error condition
                    }// End Authorization (mAuth)
                }else{
                    hud.dismiss()
                    PopupHelper.alertWithOk(title: "Empty Field", message: "All fields are required", controler: self)
                }// End Feilds condition
            }//End Progress hud
        }else{
            PopupHelper.showAlertControllerWithError(forErrorMessage: "Internet is unavailable please check your connection", forViewController: self)
        }//End Internet connectivity check statement
    }// End functions
    
    // INSERT USER RECORD INTO FIREBASE DATABASE
    func insertUserIntoDataBase(fullname:String,email:String,mobileNumber:String,location:String,password:String){
        guard let user = mAuth.currentUser?.uid else { return }
        guard let token = Messaging.messaging().fcmToken else {return}
        
        self.ref.child("Users").child(user).setValue([
            "country": self.userLocation.country ?? "",
            "email": email,
            "imageURL": "xyz",
            "latitude": self.userLocation.address_lat!,
            "location": self.userLocation.address!,
            "longitude": self.userLocation.address_lng!,
            "name": fullname,
            "number": mobileNumber,
            "password": password,
            "token": token
        ])
        // save into cache
        
        let currentuser = LoginModel (
            id: user, email: email, imageURL: "null", latitude: String(self.userLocation.address_lat), location: String(self.userLocation.address), longitude: String(self.userLocation.address_lng), name: fullname, number: mobileNumber, password: password, country: String(self.userLocation.country),token: token
        )
        CommonHelper.saveCachedUserData(currentuser)
        // Change root view controller
        PopupHelper.changeRootView(storyboardName: "Main", ViewControllerId: "Tabbar")
    }
}
