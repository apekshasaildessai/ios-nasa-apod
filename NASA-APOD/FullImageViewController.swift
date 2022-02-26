//
//  FullImageViewController.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
import UIKit
class FullImageViewController: UIViewController {
    @IBOutlet weak var zoomImageView: PanZoomImageView!
    var imageUrl: String?
    var hdImageUrl: String?
    let networkManager = Network()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if imageUrl != nil {
            loadImageData(imageUrl: imageUrl!)
        }
        if hdImageUrl != nil {
            loadImageData(imageUrl: hdImageUrl!)
        }
        
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
}
