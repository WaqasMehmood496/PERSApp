//
//  LoginViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 09/06/2021.
//

import UIKit
import JGProgressHUD
import Firebase

class LoginViewController: UIViewController {
    
    // MARK: IBOUTLET'S
    @IBOutlet weak var EmailAddressTF: UITextField!
    @IBOutlet weak var PasswordTF: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    
    // MARK: VARIABLE'S
    var ref: DatabaseReference!
    var mAuth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setupUI()
    }
    
    // MARK: ACTION'S
    @IBAction func LoginBtnAction(_ sender: Any) {
        //PopupHelper.changeRootView(storyboardName: "Main", ViewControllerId: "Tabbar")
        let email = EmailAddressTF.text!
        let password = PasswordTF.text!
        self.signInUser(email: email, password: password)
    }
    @IBAction func SignUpBtnAction(_ sender: Any) {
        self.performSegue(withIdentifier: "toSignUp", sender: nil)
    }
    @IBAction func ForgotPasswordBtnAction(_ sender: Any) {
        self.performSegue(withIdentifier: "toForgotPassword", sender: nil)
    }
    
}
//MARK:- HELPING METHOD'S EXTENSION
extension LoginViewController{
    // SETUP USER INTERFACE WITH SOME MODIFICATION
    func setupUI() {
        self.setupLeftPaddingOnTextFields()
        self.setupRightPaddingOnTextFields()
        self.buttonCustomization()
    }
    //ADD LEFT PADDING ON ALL TEXTFIELD'S
    func setupLeftPaddingOnTextFields() {
        EmailAddressTF.setLeftPaddingPoints(8)
        PasswordTF.setLeftPaddingPoints(8)
    }
    //ADD RIGHT PADDING ON ALL TEXTFIELD'S
    func setupRightPaddingOnTextFields() {
        EmailAddressTF.setRightPaddingPoints(8)
        PasswordTF.setRightPaddingPoints(8)
    }
    //ADD GRADIENT ON BUTTON
    func buttonCustomization() {
        guard let darkColor = UIColor(named: "Gradient Dark Color")?.cgColor else{return}
        guard let lightColor = UIColor(named: "Gradient Light Color")?.cgColor else{return}
        LoginButton.setGradient(colors: [darkColor,lightColor])
        LoginButton.clipsToBounds = true
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
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK:- FIREBASE METHOD'S EXTENSION
extension LoginViewController{
    // THIS METHOD WILL CHECK USER IS EXIST IN DATABASE IF IT IS THEN CHECK THAT EMAIL ENTERED IS VARIFIED OR NOT OTHERWISE SHOW ALERT
    func signInUser(email:String,password:String){
        if email != "" && password != ""{
            if Connectivity.isConnectedToNetwork(){
                showHUDView(hudIV: .indeterminate, text: .process) { (hud) in
                    hud.show(in: self.view, animated: true)
                    self.mAuth.signIn(withEmail: email, password: password) { user, error in
                        if let error = error,user == nil{
                            hud.dismiss()
                            print(error.localizedDescription)
                            print("SignInFailed")
                        }else{
                            if let user_FLag = self.mAuth.currentUser?.isEmailVerified{
                                if user_FLag{
                                    if let userID = self.mAuth.currentUser?.uid{
                                        print(userID)
                                        self.ref.child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                                            var value = snapshot.value as? NSDictionary
                                            //let key = snapshot.key as? NSDictionary
                                            let user = LoginModel(dic: value as! NSDictionary)
                                            guard let data = user else{return}
                                            CommonHelper.saveCachedUserData(data)
                                            hud.dismiss()
                                            PopupHelper.changeRootView(storyboardName: "Main", ViewControllerId: "Tabbar")
                                        }){
                                            (error) in
                                            print(error.localizedDescription)
                                            hud.dismiss()
                                        }
                                    }
                                    else{
                                        PopupHelper.alertWithOk(title: "Login Fail", message: "User not found", controler: self)
                                        hud.dismiss()
                                    }// End user id condition
                                }else{
                                    hud.dismiss()
                                    self.ErrorAlertMessage(title: "Email not verifed", description: "Kindly verify your email!")
                                }//End user_Flag statement
                            }else{
                                return
                            }//End isEmailVerified statement
                        }//End Error statement
                    }// End Authorization
                }//End JGProgress Hud
            }else{
                PopupHelper.showAlertControllerWithError(forErrorMessage: "Internet is unavailable please check your connection", forViewController: self)
            }//End Internet connectivity check statement
        }// End email and password check condition
    }// End function statement
}
