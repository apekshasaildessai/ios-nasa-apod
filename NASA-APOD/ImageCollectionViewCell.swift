//
//  ImageCollectionViewCell.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    @IBOutlet private weak var itemImageView: APODPictureView! {
        didSet {
            itemImageView.imageContentMode = .scaleAspectFill
        }
    }
    @IBOutlet private weak var titleLabel: UILabel!
    func updateTitle(title : String) {
        titleLabel.text = title
    }
    func loadImageData(imageUrl: String, shouldShowPlayButton: Bool = false) {
        itemImageView.loadImageURL(imageURL: imageUrl, shouldShowPlayButton: shouldShowPlayButton)
    }
}
