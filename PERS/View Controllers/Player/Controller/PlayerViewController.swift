//
//  PlayerViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 10/06/2021.
//

import UIKit

class PlayerViewController: UIViewController {
    
    //MARK: IBOUTLET'S
    @IBOutlet weak var RelatedVideoTableView: UICollectionView!
    //MARK: VARIABLE'S
    private let spacingIphone:CGFloat = 0.0
    private let spacingIpad:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }
    //MARK: IBACTION'S
    @IBAction func BackButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PlayerViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideosCell", for: indexPath) as! HomeCollectionViewCell
        return cell
    }
}
