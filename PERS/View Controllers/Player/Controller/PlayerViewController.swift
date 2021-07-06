//
//  PlayerViewController.swift
//  PERS
//
//  Created by Buzzware Tech on 10/06/2021.
//

import UIKit
import AVFoundation
import AVKit

class PlayerViewController: UIViewController {
    
    //MARK: IBOUTLET'S
    @IBOutlet weak var RelatedVideoTableView: UICollectionView!
    @IBOutlet weak var VideoContainerView: UIView!
    
    //MARK: VARIABLE'S
    private let spacingIphone:CGFloat = 0.0
    private let spacingIpad:CGFloat = 0.0
    let playerViewController = AVPlayerViewController()
    var playlist = AVQueuePlayer()
    var MyAreaVideos = [VideosModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        if self.MyAreaVideos.count != 0{
            player(items: getAllPlayList())
        }
    }
    
    //MARK: IBACTION'S
    @IBAction func BackButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PlayerViewController{
    //VIDEO PLAYER METHOD
    func player(items:[AVPlayerItem]) {
        print(items.count)
        
        playlist = AVQueuePlayer(items: items)
        playlist.rate = 1
        
        playerViewController.player = playlist
        playerViewController.delegate = self
        playerViewController.view.frame = self.VideoContainerView.frame
        playerViewController.showsPlaybackControls = true
        self.VideoContainerView.addSubview(playerViewController.view)
        addChild(playerViewController)
        playlist.play()
        //        playlist.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        //        playlist.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        //        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: .AVPlayerItemDidPlayToEndTime, object: playlist.currentItem)
        
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        print("Video Finished")
        self.playlist.isMuted = false
    }
    
    func getAllPlayList() -> [AVPlayerItem] {
        var items = [AVPlayerItem]()
        for video in self.MyAreaVideos{
            if let url = URL.init(string: video.videoURL) {
                print(url)
                let videoUrl = AVPlayerItem(url: url)
                items.append(videoUrl)
            }
        }
        return items
    }
}

extension PlayerViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.MyAreaVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideosCell", for: indexPath) as! HomeCollectionViewCell
        cell.PlayButton.addTarget(self, action: #selector(PlayVideoBtnAction(_:)), for: .touchUpInside)
        if let data = Data(base64Encoded: self.MyAreaVideos[indexPath.row].thumbnail){
            cell.VideoThumbnail.image = UIImage(data: data)
        }
        return cell
    }
    
    @objc func PlayVideoBtnAction(_ sender:UIButton){
        //Play video
    }
}

// MARK:- AVPlayerViewController
extension PlayerViewController:AVPlayerViewControllerDelegate,AVAudioPlayerDelegate{
    func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error) {
        print(error)
    }
}
