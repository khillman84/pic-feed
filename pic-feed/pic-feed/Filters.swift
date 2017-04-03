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
    case chrome = "CIPhotoEffectChrome"
    case poster = "CIColorPosterize"
    case colorInvert = "CIColorInvert"
}

typealias FilterCompletion = (UIImage?) -> ()

class Filters {
    
    static let shared = Filters()
    
    var context : CIContext
    
    private init() {
        let options = [kCIContextWorkingColorSpace: NSNull()] 
        guard let eaglContext = EAGLContext(api: .openGLES2) else { fatalError("Failed to creat EAGLContext.") }
        self.context = CIContext(eaglContext: eaglContext, options: options)
    }
    
    static var originalImage : UIImage?
    
     func filter(name: FilterName, image: UIImage, completion: @escaping FilterCompletion) {
        OperationQueue().addOperation {
            guard let filter = CIFilter(name: name.rawValue) else { fatalError("Failed to create CIFilter") }
            
            let coreImage = CIImage(image: image)
            filter.setValue(coreImage, forKey: kCIInputImageKey)
            
            
            //Get final image using GPU
            guard let outputImage = filter.outputImage else { fatalError("Failed to get output image from Filter") }
            
            if let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent) {
                let finalImage = UIImage(cgImage: cgImage)
                OperationQueue.main.addOperation {
                    completion(finalImage)
                }
            } else {
                OperationQueue.main.addOperation {
                    completion(nil)
                }
            }
        }
    }
}
