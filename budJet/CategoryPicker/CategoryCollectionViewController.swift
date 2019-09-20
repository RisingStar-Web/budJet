//
//  CategoryCollectionViewController.swift
//  budJet
//
//  Created by neko on 04.10.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CategoryCell"

protocol CategoryCollectionViewDelegate: class {
    func didSelectCategoryAtIndexPath(_ indexPath: IndexPath)
}

class CategoryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: CategoryCollectionViewDelegate?
    
    var typesList = [Types]() {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UINib.init(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typesList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = typesList[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
        
        cell.categoryIcon.image = UIImage(named: type.key!)
        cell.categoryTitle.text = NSLocalizedString(type.key!, comment: "")
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectCategoryAtIndexPath(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var rows: CGFloat = 3.0
        if self.view.frame.size.width > 320.0 { rows = 4.0 }
        else if self.view.frame.size.width > 375.0 { rows = 4.0 }
        return CGSize(width: (collectionView.frame.size.width - ((rows) * 10.0 + 20.0)) / rows, height: 85.0/*((collectionView.frame.size.height - ((rows - 1) * 10.0 + 20.0)) / rows)*/)
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
}
