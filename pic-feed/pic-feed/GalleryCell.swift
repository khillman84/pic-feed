//
//  GalleryCell.swift
//  pic-feed
//
//  Created by Kyle Hillman on 3/29/17.
//  Copyright © 2017 Kyle Hillman. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var post : Post! {
        didSet {
            self.imageView.image = post.image
            self.dateLabel.text = DateFormatter.localizedString(from: post.date!, dateStyle: .short, timeStyle: .short)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.dateLabel.text = nil
    }
}
