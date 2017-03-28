//
//  Filters.swift
//  pic-feed
//
//  Created by Kyle Hillman on 3/28/17.
//  Copyright © 2017 Kyle Hillman. All rights reserved.
//

import UIKit

enum FilterName : String {
    case vintage = "CIPhotoEffectTransfer"
    case blackAndWhite = "CIPhotoEffectMono"
}

typealias FilterCompletion = (UIImage?) -> ()

class Filters {
    static var originalImage = UIImage()
}
