//
//  File.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 13.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import Foundation
import CoreData

@objc(File)
class File: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var creationDate: NSDate
    @NSManaged var size: Int
    
    class var entity: NSEntityDescription {
        return NSEntityDescription.entityForName("File", inManagedObjectContext: CoreDataManager.sharedInstance.context)!
    }
    
    convenience init() {
        self.init(entity: File.entity, insertIntoManagedObjectContext: CoreDataManager.sharedInstance.context)
        self.creationDate = NSDate()
        self.name = "unnamed"
        self.size = 0
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }

    func getFileType() -> FileType? {
        return nil
    }
}
