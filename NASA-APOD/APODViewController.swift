//
//  ViewController.swift
//  NASA-APOD
//
//  Created by Apeksha on 25/02/22.
//

import UIKit
import CoreData

enum APODViewConstants {
    static let minBottomSpace = 250.0
}

class APODViewController: UIViewController {
  
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var myFavoritesButton: UIButton!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var apodPictureView: APODPictureView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField! {
        didSet {
            dateTextField.tintColor = UIColor.systemBlue
            dateTextField.setIcon(UIImage(systemName: "calendar")!)
        }
    }
    var apodDataLoader: ApodDataLoader?
    var currentAPOD: APODEntity?
    var customSpinnerView : UIView?
    var showFavoritedAPODDate: Date?
    var maxImageViewHeight: CGFloat {
        let availableHeight = view.frame.height - apodPictureView.frame.origin.y
        return availableHeight - view.frame.height/3
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(APODViewController.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        fetchAPODFor(date: YearMonthDay.today.asDate()!)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let favoritedDate = showFavoritedAPODDate {
            fetchAPODFor(date: favoritedDate)
            //reset
            showFavoritedAPODDate = nil
        }
    }
    deinit {
         NotificationCenter.default.removeObserver(self)
    }
    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
        updatePictureViewConstraints()
    }
    func setupView() {
        self.dateTextField.datePicker(target: self,
                                  doneAction: #selector(doneDateSelection),
                                  cancelAction: #selector(cancelDateSelection),
                                  datePickerMode: .date)
        
        addTapGestureToImageView()
        apodDataLoader = ApodDataLoader()
        apodPictureView.didUpdateImageHandler = { [weak self] in
            self?.updatePictureViewConstraints()
        }
        addNavBarImage()
    }
    func fetchAPODFor(date: Date) {
        showLoadingView()
        if let savedAPOD = self.apodDataLoader?.fetchSavedAPODFor(day: date) {
            updateAPODDetails(apodItem: savedAPOD)
            return
        }
        NetworkManager.shared().loadAPODData(dateString: YearMonthDay(localTime: date).description) { [weak self] apodItem in
            if apodItem != nil && apodItem?.date != nil {
                if let savedAPODEntity = self?.apodDataLoader?.saveAPOD(apodItem: apodItem!) {
                    DispatchQueue.main.async {
                        self?.updateAPODDetails(apodItem: savedAPODEntity)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.handleErrorFetchingAPOD()
                }
            }
        }
    }
    //Storyboard methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFullImageSegue" {
            if let destinationVC = segue.destination as? FullMediaViewController, let currentAPOD = currentAPOD {
                if currentAPOD.getMediaType() == .image {
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

    @objc
    func cancelDateSelection() {
        self.dateTextField.resignFirstResponder()
    }

    @objc
    func doneDateSelection() {
        if let datePickerView = self.dateTextField.inputView as? UIDatePicker {
            
            let yearMonthDay = YearMonthDay(localTime: datePickerView.date)
            self.dateLabel.text = yearMonthDay.longDate
            self.dateTextField.resignFirstResponder()
            //Update POD
            fetchAPODFor(date: datePickerView.date)
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
        apodPictureView.enableTapGestureWith(target: self, onTapAction: #selector(didTapOnImageView))
    }
    @objc
    func didTapOnImageView() {
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
            let yearMonthDay = YearMonthDay(localTime: date)
            dateLabel.text = yearMonthDay.longDate
            dateTextField.resignFirstResponder()
        }
    }
    func updateImage(apodItem: APODEntity) {
        var isVideoAsset = false
        if  apodItem.getMediaType() == .video {
            isVideoAsset = true
        }
        if let thumbnailUrl = apodItem.getThumbnailUrl() {
            apodPictureView.loadImageURL(imageURL: thumbnailUrl, shouldShowPlayButton: isVideoAsset)
        }
    }
    func updatePictureViewConstraints()  {
        if let image = apodPictureView.currentImage {
            let ratio = image.size.width / image.size.height
            var newHeight = apodPictureView.frame.width / ratio
            if newHeight > maxImageViewHeight {
                newHeight = maxImageViewHeight
            }
            imageViewHeightConstraint.constant = newHeight
            view.layoutIfNeeded()
        }
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
    func setFavoratedDate(date: Date?)  {
       showFavoritedAPODDate = date
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
    
    func removeLoadingView (completion: (() -> Void)? = nil) {
        self.dismiss(animated: false, completion: completion)
    }
    
    func handleErrorFetchingAPOD()  {
        removeLoadingView { [weak self] in
            let alert = UIAlertController(title: "Error Loading Picture for this Day", message: "No Picture found or Network Error", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
            
            if self?.currentAPOD == nil {
                //show latested saved APOD
                if let latestedAPOD = self?.apodDataLoader?.fetchLatestAPOD() {
                    self?.updateAPODDetails(apodItem: latestedAPOD)
                } else {
                    self?.showNoPictureAvailable()
                }
            }
        }
    }
    func showNoPictureAvailable() {
        titleLabel.text = "NO Image to Display. Check Device Network Connection"
        apodPictureView.showErrorImage = true
        apodPictureView.shouldShowPlayIcon = false
        dateLabel.text = ""
        descriptionLabel.text = ""
    }
}
