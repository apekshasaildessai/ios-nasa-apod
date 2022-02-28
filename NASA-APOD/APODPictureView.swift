//
//  APODPictureView.swift
//  NASA-APOD
//
//  Created by Apeksha on 27/02/22.
//

import UIKit

enum APODPictureViewConstants {
    static let nibName = "APODPictureView"
    static let loadingImageName = "image_loading"
    static let errorImageName = "image_error"
}

class APODPictureView: UIView {
    // MARK: - Properties
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var playImageView: UIImageView!
    @IBOutlet private weak var pictureImageView: UIImageView!
    var didUpdateImageHandler:  (() -> ())?
    var shouldShowPlayIcon = false {
        didSet {
            playImageView.isHidden = !shouldShowPlayIcon
        }
    }
    var showLoadingImage: Bool? {
        didSet {
            if showLoadingImage ?? false {
                pictureImageView.image = UIImage(named: APODPictureViewConstants.loadingImageName)
                if let handler = didUpdateImageHandler {
                    handler()
                }
            }
        }
    }
    var showErrorImage: Bool? {
        didSet {
            if showErrorImage ?? false {
                pictureImageView.image = UIImage(named: APODPictureViewConstants.errorImageName)
                if let handler = didUpdateImageHandler {
                    handler()
                }
            }
        }
    }
    var currentImage: UIImage? {
       get { return pictureImageView.image }
       set { pictureImageView.image = newValue }
    }
    var imageContentMode: ContentMode? {
        get { return pictureImageView.contentMode }
        set { pictureImageView.contentMode = newValue ?? .scaleAspectFit }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSubviews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    func initSubviews() {
        let nib = UINib(nibName: APODPictureViewConstants.nibName, bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
    func enableTapGestureWith<T>(target: T, onTapAction: Selector) {
        let tapRecognizer = UITapGestureRecognizer(target: target, action: onTapAction)
        tapRecognizer.numberOfTapsRequired = 1
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(tapRecognizer)
    }
    func loadImageURL(imageURL: String, isThumbnail: Bool = true, shouldShowPlayButton: Bool = false) {
        self.shouldShowPlayIcon = shouldShowPlayButton
        guard let url = URL(string: imageURL)else {
            showErrorImage = true
            return
        }
        showLoadingImage = true
        NetworkManager.shared().loadImageData(url: url) { [weak self] data, error in
            DispatchQueue.main.async {
                if data == nil {
                    self?.showErrorImage = true
                    return
                }
                guard let image = UIImage(data: data!) else {
                    self?.showErrorImage = true
                    return
                }
                self?.currentImage = image
                if let handler = self?.didUpdateImageHandler {
                    handler()
                }
            }
        }
    }
}
