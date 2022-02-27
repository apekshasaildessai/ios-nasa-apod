//
//  FullImageViewController.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
import UIKit
import YouTubeiOSPlayerHelper

class FullImageViewController: UIViewController {
    //IBoutlets
    let youtubeRegex = try! NSRegularExpression(pattern: #"://.*youtube\.com/embed/([^/?#]+)"#)
    @IBOutlet weak var zoomImageView: PanZoomImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet var videoPlayerView: YTPlayerView!
    var imageUrl: String?
    var hdImageUrl: String?
    var videoUrl: String?
    var name: String?
    let networkManager = Network()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = name
        if imageUrl != nil {
            zoomImageView.isHidden = false
            videoPlayerView.isHidden = true
            loadImageData(imageUrl: imageUrl!)
        }
        if hdImageUrl != nil {
            zoomImageView.isHidden = false
            videoPlayerView.isHidden = true
            loadImageData(imageUrl: hdImageUrl!)
        }
        if videoUrl != nil {
            zoomImageView.isHidden = true
            videoPlayerView.isHidden = false
            view.bringSubviewToFront(videoPlayerView)
            videoPlayerView.backgroundColor = UIColor.red
            playVideo(url: videoUrl!)
        }
        
    }
    //UI methods
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    func loadImageData(imageUrl: String) {
        guard let url = URL(string: imageUrl)else {
            print("Invalid url...")
            return
        }
        networkManager.loadImageData(url: url) { [weak self] data, error in
            if data != nil {
                DispatchQueue.main.async {
                    self?.zoomImageView.updateImage(data: data!)
                }
               
            }
        }
    }
    func playVideo(url: String) {
        if let match = youtubeRegex.firstMatch(in: url, range: NSRange(url.startIndex..<url.endIndex, in: url)),
           let range = Range(match.range(at: 1), in: url) {
           let videoId = String(url[range])
            
          videoPlayerView.load(withVideoId: videoId)
          
        }
    }
}
