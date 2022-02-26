//
//  ViewController.swift
//  NASA-APOD
//
//  Created by Apeksha on 25/02/22.
//

import UIKit

class ViewController: UIViewController {
  
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var apodImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    let networkManager =  Network()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadAPOD()
    }
    func loadAPOD() {
        networkManager.loadData { [weak self] apodItem in
            if apodItem != nil {
                self?.titleLabel.text = apodItem?.title
                self?.descriptionLabel.text = apodItem?.explanation
                self?.loadImageData(apodItem: apodItem!)
            }
        }
    }
    func loadImageData(apodItem: APODItem) {
        guard let urlString = apodItem.url else {
            print("Invalid url...")
            return
        }
        guard let url = URL(string: urlString)else {
            print("Invalid url...")
            return
        }
        networkManager.loadImageData(url: url) { data, error in
            if data != nil {
                DispatchQueue.main.async {
                    self.apodImageView.image = UIImage(data: data!)
                }
               
            }
        }
    }


}

