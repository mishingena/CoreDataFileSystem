//
//  FileImage.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 13.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(FileImage)
class FileImage: File {

    @NSManaged var image: UIImage
    @NSManaged var file: File

    override class var entity: NSEntityDescription {
        return NSEntityDescription.entityForName("FileImage", inManagedObjectContext: CoreDataManager.sharedInstance.context)!
    }
    
    convenience init() {
        self.init(entity: FileImage.entity, insertIntoManagedObjectContext: CoreDataManager.sharedInstance.context)
        self.creationDate = NSDate()
        self.name = "unnamed"
        self.image = UIImage()
    }
    
    convenience init(image: UIImage) {
        self.init()
        self.image = image
    }
    
    convenience init(name: String, image: UIImage) {
        self.init()
        self.name = name
        self.image = image
    }

}
