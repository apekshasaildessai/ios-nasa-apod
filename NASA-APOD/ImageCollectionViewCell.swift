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
    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    func updateTitle(title : String) {
        titleLabel.text = title
    }
    func loadImageData(imageUrl: String) {
        guard let url = URL(string: imageUrl)else {
            //Invalid url
            return
        }
        NetworkManager.shared().loadImageData(url: url) { [weak self] data, error in
            if data != nil {
                DispatchQueue.main.async {
                    self?.itemImageView.image = UIImage(data: data!)
                }
            }
        }
    }
}
