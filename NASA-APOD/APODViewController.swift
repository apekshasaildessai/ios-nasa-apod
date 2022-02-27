//
//  ViewController.swift
//  NASA-APOD
//
//  Created by Apeksha on 25/02/22.
//

import UIKit
import CoreData

class APODViewController: UIViewController {
  
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var apodImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var myFavoritesButton: UIButton!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var dateTextField: UITextField! {
        didSet {
            dateTextField.tintColor = UIColor.systemBlue
            dateTextField.setIcon(UIImage(systemName: "calendar")!)
        }
    }
    let networkManager =  Network()
    var apodDataLoader: ApodDataLoader?
    var currentAPOD: APODEntity?
    var customSpinnerView : UIView?
    var showFavoritedAPODDate: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.dateTextField.datePicker(target: self,
                                  doneAction: #selector(doneDateSelection),
                                  cancelAction: #selector(cancelDateSelection),
                                  datePickerMode: .date)
        
        addTapGestureToImageView()
        apodDataLoader = ApodDataLoader()
        fetchAPODFor(date: YearMonthDay.today.description)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        if let favoritedDate = showFavoritedAPODDate {
            fetchAPODFor(date: favoritedDate)
            //reset
            showFavoritedAPODDate = nil
        }
    }
    func fetchAPODFor(date: String) {
        showLoadingView()
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
                if getMediaTypeFor(apodEntity: currentAPOD) == .image {
                    destinationVC.imageUrl = currentAPOD.url
                    destinationVC.hdImageUrl = currentAPOD.hdUrl
                } else {
                    destinationVC.videoUrl = currentAPOD.url
                }
                destinationVC.name = currentAPOD.title
            }
        }
    }
    //UI methods
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        if let apodEntity = currentAPOD {
            apodEntity.isFavorite = !apodEntity.isFavorite
            apodDataLoader?.saveFavorite(apodItem: apodEntity)
            updateFavoriteButton()
        }
        
    }
    @IBAction func myFavoriteButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showMyFavoritesView", sender: nil)
    }
    func setupView() {
        addNavBarImage()
//        self.navigationItem.title = "Astronomy Picture of the Day"
//        self.navigationItem.prompt = "Today's"
    }
    @objc
    func cancelDateSelection() {
        self.dateTextField.resignFirstResponder()
    }

    @objc
    func doneDateSelection() {
        if let datePickerView = self.dateTextField.inputView as? UIDatePicker {
            
            let yearMonthDay = YearMonthDay(localTime: datePickerView.date)
            self.dateTextField.text = yearMonthDay.description
            self.dateTextField.resignFirstResponder()
            //Update POD
            fetchAPODFor(date: yearMonthDay.description)
        }
    }
    func addNavBarImage() {
        let navController = navigationController!
        let image = UIImage(named: "logo")
        let imageView = UIImageView(image: image)
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
        let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    func addTapGestureToImageView() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnImageView(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        apodImageView.isUserInteractionEnabled = true
        apodImageView.addGestureRecognizer(tapRecognizer)
    }
//    func showHideDatePickerWithDate(date: Date?) {
//        if let givenDate = date {
//            datePicker.date = givenDate
//        }
//        datePicker.isHidden = !datePicker.isHidden
//    }
    @objc private func didTapOnImageView(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showFullImageSegue", sender: nil)
    }
    func updateAPODDetails(apodItem: APODEntity) {
        removeLoadingView()
        currentAPOD = apodItem
        titleLabel.text = apodItem.title
        descriptionLabel.text = apodItem.explanation
        updateFavoriteButton()
        updateImage(apodItem: apodItem)
        
        //Update Date on picker
        //TODO: remove force unwrapping
        if let date = currentAPOD?.date {
            let yearMonthDay = YearMonthDay(date)
            dateTextField.text = " " + yearMonthDay!.description
            dateTextField.resignFirstResponder()
        }
    }

    func updateImage(apodItem: APODEntity) {
        if let thumbnailUrl = getThumbnailUrl(apodEntity: apodItem) {
            downloadImageData(urlString: thumbnailUrl)
        }
        let mediaType = getMediaTypeFor(apodEntity: apodItem)
        switch mediaType {
        case .image:
            playImageView.isHidden = true
        case .video:
            playImageView.isHidden = false
        default:
            playImageView.isHidden = true
        }
    }
    func downloadImageData(urlString: String) {
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
        var newHeight = apodImageView.frame.width / ratio
        if newHeight > maxImageViewHeight() {
            newHeight = maxImageViewHeight()
        }
        imageViewHeightConstraint.constant = newHeight
        view.layoutIfNeeded()
    }
    func updateFavoriteButton()  {
        if let apodEntity = currentAPOD {
            //update button image
            var image: UIImage?
            if apodEntity.isFavorite {
                image = UIImage(systemName: "star.fill")
            } else {
                image = UIImage(systemName: "star")
            }
            if image != nil {
                favoriteButton.setImage(image, for: .normal)
            }
        }
    }
    func setFavoratedDate(date: String)  {
       showFavoritedAPODDate = date
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
    func maxImageViewHeight() -> CGFloat {
        let availableHeight = view.frame.height - apodImageView.frame.origin.y
        return availableHeight - 200
    }
    func getThumbnailUrl(apodEntity: APODEntity) -> String? {
        let apodMediaType = getMediaTypeFor(apodEntity: apodEntity)
        switch apodMediaType {
        case .image:
            return apodEntity.url
        case .video:
            return apodEntity.thumbnail
        default:
            return nil
        }
    }
}
extension APODViewController {
    func showLoadingView () {
        let loadingVC = LoadingViewController()

        // Animate loadingVC over the existing views on screen
        loadingVC.modalPresentationStyle = .overCurrentContext

        // Animate loadingVC with a fade in animation
        loadingVC.modalTransitionStyle = .crossDissolve
               
        present(loadingVC, animated: true, completion: nil)
    }
    
    func removeLoadingView () {
        self.dismiss(animated: false, completion: nil)
    }
}
