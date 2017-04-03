//
//  GalleryCollectionViewLayout.swift
//  pic-feed
//
//  Created by Kyle Hillman on 3/29/17.
//  Copyright © 2017 Kyle Hillman. All rights reserved.
//

import UIKit

class GalleryCollectionViewLayout: UICollectionViewFlowLayout { //Snippet
    
    var columns = 2
    let spacing : CGFloat = 1.0
    
    var screenWidth : CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var itemWidth : CGFloat {
        let availableScreen = screenWidth - (CGFloat(self.columns) * self.spacing)
        return availableScreen / CGFloat(self.columns)
    }
    
    init(columns : Int = 1) {
        self.columns = columns
        
        super.init()
        
        self.minimumLineSpacing = spacing
        self.minimumInteritemSpacing = spacing
        self.itemSize = CGSize(width: itemWidth, height: itemWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
