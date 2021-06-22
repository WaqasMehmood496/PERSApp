//
//  TabbarController.swift
//  PERS
//
//  Created by Buzzware Tech on 09/06/2021.
//

import UIKit

class TabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let tabBar = self.tabBar
        tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: UIColor.white, size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count)-16, height: tabBar.frame.height), lineWidth: 1.0)
    }
    override func viewWillAppear(_ animated: Bool) {
        let topColor = UIColor(named: "Gradient Dark Color")
        let bottomColor = UIColor(named: "Gradient Light Color")
        let navFrame = self.tabBar.bounds
        let frame = CGRect(x: navFrame.origin.x, y: navFrame.origin.y, width: navFrame.width, height: navFrame.height + UIApplication.shared.statusBarFrame.size.height)
        self.tabBar.barTintColor = UIColor(gradientStyle: .topToBottom, withFrame: frame, andColors: [topColor,bottomColor])
    }
    
}
