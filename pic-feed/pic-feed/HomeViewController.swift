//
//  HomeViewController.swift
//  pic-feed
//
//  Created by Kyle Hillman on 3/27/17.
//  Copyright © 2017 Kyle Hillman. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        let defaultImage = imageView.image
        Filters.originalImage = defaultImage!
        self.collectionView.dataSource = self
        setupGalleryDelegate()
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
        guard let image = self.imageView.image else { return }
        
        self.collectionViewHeightConstraint.constant = 150
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
//        let alertController = UIAlertController(title: "Filter", message: "Please select a filter", preferredStyle: .alert)
//        
//        let backAndWhiteAction = UIAlertAction(title: "Black", style: .default) { (action) in
//            Filters.filter(name: .blackAndWhite, image: image, completion: { (filteredImage) in
//                self.imageView.image = filteredImage
//            })
//        }
//        
//        let vintageAction = UIAlertAction(title: "Vintage", style: .default) { (action) in
//            Filters.filter(name: .vintage, image: image, completion: { (filteredImage) in
//                self.imageView.image = filteredImage
//            })
//        }
//        
//        let chromeAction = UIAlertAction(title: "Chrome", style: .default) { (action) in
//            Filters.filter(name: .chrome, image: image, completion: { (filteredImage) in
//                self.imageView.image = filteredImage
//            })
//        }
//        
//        let posterAction = UIAlertAction(title: "Poster", style: .default) { (action) in
//            Filters.filter(name: .poster, image: image, completion: { (filteredImage) in
//                self.imageView.image = filteredImage
//            })
//        }
//        
//        let colorInvertAction = UIAlertAction(title: "Color Invert", style: .default) { (action) in
//            Filters.filter(name: .colorInvert, image: image, completion: { (filteredImage) in
//                self.imageView.image = filteredImage
//            })
//        }
//        
//        let resetAction = UIAlertAction(title: "Reset Image", style: .destructive) { (action) in
//            self.imageView.image = Filters.originalImage
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        alertController.addAction(backAndWhiteAction)
//        alertController.addAction(vintageAction)
//        alertController.addAction(chromeAction)
//        alertController.addAction(posterAction)
//        alertController.addAction(colorInvertAction)
//        alertController.addAction(resetAction)
//        alertController.addAction(cancelAction)
//        
//        self.present(alertController, animated: true, completion: nil)
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
extension HomeViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.identifier, for: indexPath) as! FilterCell
        
        guard let originalImage = Filters.originalImage else { return filterCell }
        
        guard let resizedImage = originalImage.resize(size: CGSize(width: 150, height: 150)) else { return filterCell }
        
        let filterName = self.filterNames[indexPath.row]
        
        Filters.filter(name: filterName, image: resizedImage) { (filteredImage) in
            filterCell.imageView.image = filteredImage
        }
        
        return filterCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
}

extension HomeViewController: GalleryViewControllerDelegate {
    func galleryController(didSelect image: UIImage) {
        self.imageView.image = image
        self.tabBarController?.selectedIndex = 0
        
    }
}


























