//
//  ImageFile.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 10.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(ImageFile)
class ImageFile: NSManagedObject {

    @NSManaged var image: UIImage
    @NSManaged var name: String
    @NSManaged var folder: Folder

}
