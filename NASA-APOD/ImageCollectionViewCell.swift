//
//  ImageCollectionViewCell.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var itemImageView: UIImageView!
    var networkManager = Network()
    func loadImageData(imageUrl: String) {
        guard let url = URL(string: imageUrl)else {
            print("Invalid url...")
            return
        }
        networkManager.loadImageData(url: url) { [weak self] data, error in
            if data != nil {
                DispatchQueue.main.async {
                    self?.itemImageView.image = UIImage(data: data!)
                }
            }
        }
    }
}
