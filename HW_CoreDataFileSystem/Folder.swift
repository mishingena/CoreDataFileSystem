//
//  Folder.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 10.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import Foundation
import CoreData

@objc(Folder)
class Folder: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var folders: NSSet
    @NSManaged var imageFiles: NSSet
    @NSManaged var textFiles: NSSet

    class var entity: NSEntityDescription {
        return NSEntityDescription.entityForName("Folder", inManagedObjectContext: CoreDataManager.sharedInstance.context)!
    }
    
    convenience init() {
        self.init(entity: Folder.entity, insertIntoManagedObjectContext: CoreDataManager.sharedInstance.context)
    }
}