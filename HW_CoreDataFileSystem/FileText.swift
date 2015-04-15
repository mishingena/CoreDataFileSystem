//
//  FileText.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 13.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import Foundation
import CoreData

@objc(FileText)
class FileText: File {

    @NSManaged var text: String
    @NSManaged var file: File

    override class var entity: NSEntityDescription {
        return NSEntityDescription.entityForName("FileText", inManagedObjectContext: CoreDataManager.sharedInstance.context)!
    }
    
    convenience init() {
        self.init(entity: FileText.entity, insertIntoManagedObjectContext: CoreDataManager.sharedInstance.context)
        self.text = ""
        self.creationDate = NSDate()
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
