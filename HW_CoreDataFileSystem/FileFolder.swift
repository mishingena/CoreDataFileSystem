//
//  FileFolder.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 14.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import Foundation
import CoreData

@objc(FileFolder)
class FileFolder: File {

    @NSManaged var isRoot: Bool
    @NSManaged var files: NSSet

    override class var entity: NSEntityDescription {
        return NSEntityDescription.entityForName("FileFolder", inManagedObjectContext: CoreDataManager.sharedInstance.context)!
    }
    
    convenience init() {
        self.init(entity: FileFolder.entity, insertIntoManagedObjectContext: CoreDataManager.sharedInstance.context)
        self.creationDate = NSDate()
        self.isRoot = false
        self.name = "unnamed"
        self.files = NSSet()
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    override func getFileType() -> FileType? {
        return .Folder
    }
    
}
