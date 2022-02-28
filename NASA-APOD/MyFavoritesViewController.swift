//
//  MyFavoritesViewController.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
import UIKit

enum MyFavoriteViewConstants {
    static let minCellSize = 150
    static let favoriteCellIdentifier = "dataCell"
    static let title = "My Favorites"
}

class MyFavoritesViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var backButton: UIButton!
    private var myFavoriteAPODs =  [APODEntity]()
    private var apodDataLoader: ApodDataLoader?
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //init
        collectionView.dataSource = self
        collectionView.delegate = self
        apodDataLoader = ApodDataLoader()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    // MARK: - UI Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - UI update methods
    func setupView() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = MyFavoriteViewConstants.title
        updateList()
    }
    func updateList() {
        myFavoriteAPODs = apodDataLoader?.fetchMyFavoriteAPODs() ??  [APODEntity]()
        collectionView.reloadData()
    }
}
extension MyFavoritesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myFavoriteAPODs.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyFavoriteViewConstants.favoriteCellIdentifier, for: indexPath) as! ImageCollectionViewCell
        let apodEntity = myFavoriteAPODs[indexPath.row]
        cell.updateTitle(title: apodEntity.title ?? "Title")
        let isVideo = apodEntity.getMediaType() == .video
        cell.loadImageData(imageUrl: apodEntity.getThumbnailUrl() ?? "", shouldShowPlayButton: isVideo)
        return cell
    }
}
extension MyFavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //TODO: Calculate and return
        return CGSize(width: MyFavoriteViewConstants.minCellSize, height: MyFavoriteViewConstants.minCellSize)

    }
}
extension MyFavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //get selected apod item
        let apodEntity = myFavoriteAPODs[indexPath.row]
        //Set value in APODViewController
        if let apodViewController = navigationController?.viewControllers.first as? APODViewController {
            apodViewController.setFavoratedDate(date: apodEntity.date)
        }
        //pop to apodViewController
        navigationController?.popToRootViewController(animated: false)
       
    }
}
