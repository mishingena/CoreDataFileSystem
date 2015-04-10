//
//  TextFile.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 10.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import Foundation
import CoreData

@objc(TextFile)
class TextFile: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var text: String
    @NSManaged var folder: Folder

    class var entity: NSEntityDescription {
        return NSEntityDescription.entityForName("TextFile", inManagedObjectContext: CoreDataManager.sharedInstance.context)!
    }
    
    convenience init() {
        self.init(entity: TextFile.entity, insertIntoManagedObjectContext: CoreDataManager.sharedInstance.context)
    }
}
