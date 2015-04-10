//
//  CoreDataManager.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 10.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    enum Element {
        case Folder
        case TextFile
        case ImageFile
    }
    
    class var sharedInstance: CoreDataManager {
        struct Singleton {
            static let instance = CoreDataManager()
        }
        return Singleton.instance
    }
    
    let coordinator: NSPersistentStoreCoordinator
    let model: NSManagedObjectModel
    let context: NSManagedObjectContext
    let queue: dispatch_queue_t
    
    private override init() {
        let modelURL = NSBundle.mainBundle().URLForResource("HW_CoreDataFileSystem", withExtension: "momd")!
        model = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        let fileManager = NSFileManager.defaultManager()
        let docsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as NSURL
        let storeURL = docsURL.URLByAppendingPathComponent("HW_CoreDataFileSystem.sqlite")
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: nil)
        if store == nil {
            abort()
        }
        
        context = NSManagedObjectContext()
        context.persistentStoreCoordinator = coordinator
        
        queue = dispatch_queue_create("CoreData queue", DISPATCH_QUEUE_SERIAL)
        
        super.init()
    }
    
}
