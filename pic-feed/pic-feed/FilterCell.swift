//
//  FilterCell.swift
//  pic-feed
//
//  Created by Kyle Hillman on 3/30/17.
//  Copyright © 2017 Kyle Hillman. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
    }
}
