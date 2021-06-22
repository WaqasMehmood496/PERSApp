//
//  GradientNavigationVC.swift
//  PERS
//
//  Created by Buzzware Tech on 09/06/2021.
//

import UIKit
import ChameleonFramework

class GradientNavigationVC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        let topColor = UIColor(named: "Gradient Dark Color")
        let bottomColor = UIColor(named: "Gradient Light Color")
        let navFrame = self.navigationBar.bounds
        let frame = CGRect(x: navFrame.origin.x, y: navFrame.origin.y, width: navFrame.width, height: navFrame.height + UIApplication.shared.statusBarFrame.size.height)
        self.navigationBar.barTintColor = UIColor(gradientStyle: .topToBottom, withFrame: frame, andColors: [topColor,bottomColor])
    }
    
}
