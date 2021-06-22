//
//  ForgotPasswordViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 10/06/2021.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    //MARK: IBOUTLET'S
    @IBOutlet weak var EmailTF: UITextField!
    @IBOutlet weak var SendBtn: UIButton!
    //MARK: VARIABLE'S
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
}

//MARK:- FUNCTION'S EXTENSION
extension ForgotPasswordViewController{
    func setupUI() {
        // Left padding of textfield
        EmailTF.setLeftPaddingPoints(8)
        // Right Padding of textfield
        EmailTF.setRightPaddingPoints(8)
        // Set Gradient on button
        guard let darkColor = UIColor(named: "Gradient Dark Color")?.cgColor else{return}
        guard let lightColor = UIColor(named: "Gradient Light Color")?.cgColor else{return}
        SendBtn.setGradient(colors: [darkColor,lightColor])
        SendBtn.clipsToBounds = true
    }
}
