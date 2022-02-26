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
}

class MyFavoritesViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var myFavoriteAPODs =  [APODEntity]()
    var apodDataLoader: ApodDataLoader?
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        apodDataLoader = ApodDataLoader()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateList()
    }
    func updateList() {
        myFavoriteAPODs = apodDataLoader?.fetchMyFavoriteAPOD() ??  [APODEntity]()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dataCell", for: indexPath) as! ImageCollectionViewCell
        let apodEntity = myFavoriteAPODs[indexPath.row]
        cell.loadImageData(imageUrl: apodEntity.url ?? "")
        return cell
    }
    
}
extension MyFavoritesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //TODO: Calculate and return
        return CGSize(width: 300, height: 300)

    }
}
