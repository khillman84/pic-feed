//
//  CloudKit.swift
//  pic-feed
//
//  Created by Kyle Hillman on 3/27/17.
//  Copyright © 2017 Kyle Hillman. All rights reserved.
//

import Foundation
import CloudKit

class CloudKit {
    
    static let shared = CloudKit()
    
    let container = CKContainer.default()
    
    var privateDatabase : CKDatabase {
        return container.privateCloudDatabase
    }
}
