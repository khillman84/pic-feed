//
//  HomeViewController.swift
//  pic-feed
//
//  Created by Kyle Hillman on 3/27/17.
//  Copyright © 2017 Kyle Hillman. All rights reserved.
//

import UIKit
import Social

class HomeViewController: UIViewController, UINavigationControllerDelegate {
    
    let filterNames = [FilterName.vintage, FilterName.blackAndWhite, FilterName.chrome , FilterName.poster , FilterName.colorInvert]
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textBottomConstraing: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        setupGalleryDelegate()
        Filters.originalImage = imageView.image
    }
    
    func setupGalleryDelegate(){
        if let tabBarController = self.tabBarController {
            guard let viewControllers = tabBarController.viewControllers else { return }
            guard let galleryController = viewControllers[1] as? GalleryViewController else { return }
            galleryController.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        filterButtonTopConstraint.constant = 4
        postButtonBottomConstraint.constant = 8
        textBottomConstraing.constant = 7
        
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    //MARK: Actions
    @IBAction func imageTapped(_ sender: Any) {
        print("user tapped image")
        self.presentActionSheet()
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        if let image = self.imageView.image {
            let newPost = Post(image: image, date: nil)
            CloudKit.shared.save(post: newPost, completion: { (success) in
                if success {
                    print("Saved Post successfully to Cloudkit")
                } else {
                    print("We did not successfully save to Cloudkit")
                }
            })
        }
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        
        if  self.collectionViewHeightConstraint.constant == 0 {
            self.collectionViewHeightConstraint.constant = 150
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.collectionViewHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    @IBAction func userLongPressed(_ sender: UILongPressGestureRecognizer) {
        if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)){
            guard let composeController = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else { return }
            composeController.add(self.imageView.image)
            self.present(composeController, animated: true, completion: nil)
        }
    }
    
    func presentActionSheet(){
        let actionSheetController = UIAlertController(title: "Source", message: "Please select source type", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .camera)
        }
        
        let photoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        actionSheetController.addAction(cameraAction)
        actionSheetController.addAction(photoAction)
        actionSheetController.addAction(cancelAction)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

//MARK: UICollectionViewDataSource
extension HomeViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.identifier, for: indexPath) as! FilterCell
        
        guard let originalImage = Filters.originalImage else { return filterCell }
        
        guard let resizedImage = originalImage.resize(size: CGSize(width: 150, height: 150)) else { return filterCell }
        
        let filterName = self.filterNames[indexPath.row]
        
        Filters.shared.filter(name: filterName, image: resizedImage) { (filteredImage) in
            filterCell.imageView.image = filteredImage
            filterCell.filterLabel.text = String(describing: filterName)
        }
        return filterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        guard let image = Filters.originalImage else { return }
        let filter = self.filterNames[indexPath.row]
        Filters.shared.filter(name: filter, image: image) { (filteredImage) in
            self.imageView.image = filteredImage
        }
    }
}


//MARK: Image Picker Controller Delegate
extension HomeViewController : UIImagePickerControllerDelegate {
    
    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType){
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = sourceType
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.imageView.image = originalImage
            Filters.originalImage = originalImage
            self.collectionView.reloadData()
        }
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: Gallery View Controller Delegate
extension HomeViewController: GalleryViewControllerDelegate {
    func galleryController(didSelect image: UIImage) {
        self.imageView.image = image
        Filters.originalImage = image
        self.tabBarController?.selectedIndex = 0
        
    }
}
