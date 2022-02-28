//
//  FullMediaViewController.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
import UIKit
import YouTubeiOSPlayerHelper

class FullMediaViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet private weak var zoomImageView: PanZoomImageView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private var videoPlayerView: YTPlayerView!
    var imageUrl: String?
    var hdImageUrl: String?
    var videoUrl: String?
    var name: String?
    lazy var youtubeRegex: NSRegularExpression? = {
        return try? NSRegularExpression(pattern: MediaConstants.youtubeRegex)
    }()
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMedia()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = name
    }
    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK: - UI update methods
    func loadMedia() {
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
            loadVideo(url: videoUrl!)
        }
    }
    func loadImageData(imageUrl: String) {
        guard let url = URL(string: imageUrl)else {
            print("Invalid url...")
            return
        }
        NetworkManager.shared().loadImageData(url: url) { [weak self] data, error in
            if data != nil {
                DispatchQueue.main.async {
                    self?.zoomImageView.updateImage(data: data!)
                }
            }
        }
    }
    func loadVideo(url: String) {
        guard let videoRegex = youtubeRegex else {
            //Not a youtube video
            showVideoNotSupportedAlert()
            return
        }
        //Play video by videoID. Get videoID from URL
        if let match = videoRegex.firstMatch(in: url, range: NSRange(url.startIndex..<url.endIndex, in: url)),
           let range = Range(match.range(at: 1), in: url) {
           let videoId = String(url[range])
           videoPlayerView.load(withVideoId: videoId)
           return
        }
        showVideoNotSupportedAlert()
    }
    func showVideoNotSupportedAlert() {
        //TODO:
    }
}
