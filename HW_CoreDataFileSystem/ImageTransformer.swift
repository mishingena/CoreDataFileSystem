//
//  ImageTransformer.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 10.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

class ImageTransformer: NSValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return UIImage.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        return UIImageJPEGRepresentation(value as! UIImage, 0.8)
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        return UIImage(data: value as! NSData)
    }
}
