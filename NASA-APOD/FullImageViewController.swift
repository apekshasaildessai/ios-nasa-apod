//
//  FullImageViewController.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
import UIKit
class FullImageViewController: UIViewController {
    //IBoutlets
    @IBOutlet weak var zoomImageView: PanZoomImageView!
    @IBOutlet weak var backButton: UIButton!
    var imageUrl: String?
    var hdImageUrl: String?
    var name: String?
    let networkManager = Network()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = name
        if imageUrl != nil {
            loadImageData(imageUrl: imageUrl!)
        }
        if hdImageUrl != nil {
            loadImageData(imageUrl: hdImageUrl!)
        }
        
    }
    //UI methods
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
