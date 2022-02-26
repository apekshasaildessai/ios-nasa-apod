//
//  ViewController.swift
//  NASA-APOD
//
//  Created by Apeksha on 25/02/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {
  
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var apodImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var myFavoritesButton: UIButton!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    let networkManager =  Network()
    var apodDataLoader: ApodDataLoader?
    var currentAPOD: APODEntity?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addTapGestureToImageView()
        apodDataLoader = ApodDataLoader()
        fetchAPODFor(date: YearMonthDay.today.description)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func fetchAPODFor(date: String) {
        if let savedAPOD = self.apodDataLoader?.fetchSavedAPODFor(day: date) {
            updateAPODDetails(apodItem: savedAPOD)
            return
        }
        networkManager.loadAPODData(dateString: date) { [weak self] apodItem in
            if apodItem != nil {
                if let savedAPODEntity = self?.apodDataLoader?.saveAPOD(apodItem: apodItem!) {
                    self?.updateAPODDetails(apodItem: savedAPODEntity)
                }
                
            }
        }
    }
    //Storyboard methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFullImageSegue" {
            if let destinationVC = segue.destination as? FullImageViewController, let currentAPOD = currentAPOD {
                destinationVC.imageUrl = currentAPOD.url
                destinationVC.hdImageUrl = currentAPOD.hdUrl
            }
        }
    }
    //UI methods
    @IBAction func datePickerChanged(_ sender: Any) {
        let yearMonthDay = YearMonthDay(localTime: datePicker.date)
        fetchAPODFor(date: yearMonthDay.description)
    }
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        if let apodEntity = currentAPOD {
            apodEntity.isFavorite = !apodEntity.isFavorite
            apodDataLoader?.saveFavorite(apodItem: apodEntity)
            updateFavoriteButton()
        }
        
    }
    @IBAction func myFavoriteButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showMyFavoritesView", sender: nil)
//        let myFavorite = apodDataLoader?.fetchMyFavoriteAPODs()
    }
    func addTapGestureToImageView() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnImageView(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        apodImageView.isUserInteractionEnabled = true
        apodImageView.addGestureRecognizer(tapRecognizer)
    }
    func showHideDatePickerWithDate(date: Date?) {
        if let givenDate = date {
            datePicker.date = givenDate
        }
        datePicker.isHidden = !datePicker.isHidden
    }
    @objc private func didTapOnImageView(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showFullImageSegue", sender: nil)
    }
    func updateAPODDetails(apodItem: APODEntity) {
        currentAPOD = apodItem
        titleLabel.text = apodItem.title
        descriptionLabel.text = apodItem.explanation
        updateFavoriteButton()
        loadImageData(apodItem: apodItem)
    }
    
    func loadImageData(apodItem: APODEntity) {
        guard let urlString = apodItem.url else {
            print("Invalid url...")
            return
        }
        guard let url = URL(string: urlString)else {
            print("Invalid url...")
            return
        }
        networkManager.loadImageData(url: url) { [weak self] data, error in
            if data != nil {
                DispatchQueue.main.async {
                    self?.updateImage(data: data!)
                }
               
            }
        }
    }
    func updateImage(data: Data) {
        guard let image = UIImage(data: data) else {
            return
        }
        apodImageView.image = image
        let ratio = image.size.width / image.size.height
        let newHeight = apodImageView.frame.width / ratio
        imageViewHeightConstraint.constant = newHeight
        view.layoutIfNeeded()
    }
    func updateFavoriteButton()  {
        if let apodEntity = currentAPOD {
            //update button image
            var image: UIImage?
            if apodEntity.isFavorite {
                image = UIImage(systemName: "heart.fill")
            } else {
                image = UIImage(systemName: "heart")
            }
            if image != nil {
                favoriteButton.setImage(image, for: .normal)
            }
        }
    }
}

