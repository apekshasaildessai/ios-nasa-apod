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
    var managedObjectContext: NSManagedObjectContext?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        managedObjectContext = PersistenceController.shared.container.viewContext
        fetchAPODFor(date: YearMonthDay.today.description)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        datePicker.isHidden = true
    }
    func fetchAPODFor(date: String) {
        if let savedAPOD = self.fetchSavedAPODFor(day: date) {
            updateAPODDetails(apodItem: savedAPOD)
            return
        }
        networkManager.loadAPODData(dateString: date) { [weak self] apodItem in
            if apodItem != nil {
                if let savedAPODEntity = self?.saveAPOD(apodItem: apodItem!) {
                    self?.updateAPODDetails(apodItem: savedAPODEntity)
                }
                
            }
        }
    }
    //UI methods
    @IBAction func datePickerChanged(_ sender: Any) {
        let yearMonthDay = YearMonthDay(localTime: datePicker.date)
        fetchAPODFor(date: yearMonthDay.description)
    }
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        
    }
    @IBAction func myFavoriteButtonTapped(_ sender: Any) {
        
    }
    func showHideDatePickerWithDate(date: Date?) {
        if let givenDate = date {
            datePicker.date = givenDate
        }
        datePicker.isHidden = !datePicker.isHidden
    }
    func updateAPODDetails(apodItem: APODEntity) {
        titleLabel.text = apodItem.title
        descriptionLabel.text = apodItem.explanation
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
    func saveAPOD(apodItem: APODItem) -> APODEntity {
        guard let managedObjectContext = managedObjectContext else {
            fatalError("No Managed Object Context Available")
        }
        // Create APOD Entity
        let apodEntity = APODEntity(context: managedObjectContext)
        apodEntity.date = apodItem.date
        apodEntity.thumbnail = apodItem.thumbnail_url
        apodEntity.explanation = apodItem.explanation
        apodEntity.url = apodItem.url
        apodEntity.hdUrl = apodItem.hdurl
        apodEntity.title = apodItem.title
        apodEntity.mediaType = apodEntity.mediaType
        
        PersistenceController.shared.save()
        return apodEntity
    }
    
    func fetchSavedAPODFor(day: String) -> APODEntity? {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<APODEntity> = APODEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "date = %@", day
        )
        let context = PersistenceController.shared.container.viewContext
        
        do {
            // Execute Fetch Request
            let apodEntity = try context.fetch(fetchRequest).first
            return apodEntity

        } catch {
            print("Unable to Execute Fetch Request, \(error)")
        }
        return nil
    }


}

