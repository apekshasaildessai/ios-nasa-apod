//
//  APODPictureView.swift
//  NASA-APOD
//
//  Created by Apeksha on 27/02/22.
//

import UIKit
enum APODPictureViewConstants {
    static let nibName = "APODPictureView"
}

class APODPictureView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var pictureImageView: UIImageView!
    var shouldShowPlay = false {
        didSet {
            playImageView.isHidden = !shouldShowPlay
        }
    }
    var showLoadingImage: Bool? {
        didSet {
            if showLoadingImage ?? false {
                pictureImageView.image = UIImage(named: "image_loading")
            }
        }
    }
    var showErrorImage: Bool? {
        didSet {
            if showLoadingImage ?? false {
                pictureImageView.image = UIImage(named: "image_error")
            }
        }
    }
    var thumbailImage: UIImage? {
       get { return pictureImageView.image }
       set { pictureImageView.image = newValue }
    }
    var hdImage: UIImage? {
       get { return pictureImageView.image }
       set { pictureImageView.image = newValue }
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
        // standard initialization logic
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
}
