//
//  ViewController.swift
//  NASA-APOD
//
//  Created by Apeksha on 25/02/22.
//

import UIKit
import CoreData
import AVKit

class APODViewController: UIViewController {
  
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
    var newDatePicker: UIDatePicker?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addTapGestureToImageView()
        apodDataLoader = ApodDataLoader()
        fetchAPODFor(date: YearMonthDay.today.description)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentAPOD != nil {
            updateAPODDetails(apodItem: currentAPOD!)
        }
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
                destinationVC.name = currentAPOD.title
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
        
//        showDatePicker()
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
        guard let apodEntity = currentAPOD else {
            return
        }
        let mediaType = getMediaTypeFor(apodEntity: apodEntity)
        switch mediaType {
        case .image:
            performSegue(withIdentifier: "showFullImageSegue", sender: nil)
        case .video:
            showVideoView()
        default:
            return
        }
    }
    func updateAPODDetails(apodItem: APODEntity) {
        currentAPOD = apodItem
        titleLabel.text = apodItem.title
        descriptionLabel.text = apodItem.explanation
        updateFavoriteButton()
        loadImageData(apodItem: apodItem)
        
        //Update Date on picker
        //TODO: remove force unwrapping
        let yearMonthDay = YearMonthDay(currentAPOD!.date!)
        datePicker.date = yearMonthDay!.asDate()!
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
    func showVideoView() {
        guard let url = URL(string: currentAPOD?.url ?? "")else {return}
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player

        present(vc, animated: true) {
            vc.player?.play()
        }
    }
    func updateCurrentPOD(date: String)  {
        fetchAPODFor(date: date)
    }
    //Utility method
    func getMediaTypeFor(apodEntity: APODEntity) -> APODMediaType {
        guard let mediaType = currentAPOD?.mediaType else {
            return APODMediaType.unknown
        }
        if let apodMediaType = APODMediaType.init(rawValue: mediaType) {
            return apodMediaType
        }
        return APODMediaType.unknown
    }
    
    func showDatePicker() {
        newDatePicker = UIDatePicker()
        newDatePicker?.date = Date()
        newDatePicker?.locale = .current
        newDatePicker?.preferredDatePickerStyle = .inline
//            newDatePicker?.addTarget(self, action: #selector(dateSet), for: .valueChanged)
            addDatePickerToSubview()
        }

        func addDatePickerToSubview() {
            guard let datePicker = newDatePicker else { return }
            // Give the background Blur Effect
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(blurEffectView)
            self.view.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            centerDatePicker()
            view.bringSubviewToFront(datePicker)
        }

        func centerDatePicker() {
            guard let datePicker = newDatePicker else { return }
            // Center the Date Picker
            datePicker.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            datePicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        }
}

