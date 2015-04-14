//
//  CoreDataManager.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 10.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit
import CoreData
import Foundation

enum FileType {
    case Folder
    case TextFile
    case ImageFile
}

class CoreDataManager: NSObject {
    
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
        let docsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as! NSURL
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
    
    func getRootFolder(completion:(FileFolder) -> ()) {
        dispatch_async(queue, { () -> Void in
            var error: NSError?
            let request = NSFetchRequest(entityName: "FileFolder")
            let predicate = NSPredicate(format: "isRoot == true")
            request.predicate = predicate
//            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
//            let sortDescriptors = NSArray(object: sortDescriptor)
//            request.sortDescriptors = sortDescriptors as [AnyObject]
            
            var result = self.context.executeFetchRequest(request, error: &error)
            
            assert(result?.count < 2, "Error, more than one root folder")
            if let error = error {
                abort()
            }
            
            if result?.count == 0 {
                let rootFolder = FileFolder(name: "Root")
                rootFolder.isRoot = true
                self.save()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(rootFolder)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(result?.first as! FileFolder)
                })
            }
        })
    }
    
    func addFileToFolder(folder: FileFolder, file: File, completed:() -> ()) {
        dispatch_async(queue, { () -> Void in
            var files = NSMutableSet(set: folder.files)
            files.addObject(file)
            folder.files = files
            self.save()
        })
        dispatch_barrier_async(queue, { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completed()
            })
        })
    }
    
    func save() {
        dispatch_async(queue, { () -> Void in
            var error: NSError?
            if !self.context.save(&error){
                abort()
            }
        })
    }
    
    func deleteFile(file: File, fromFolder folder: FileFolder, completed: () -> ()) {
        dispatch_async(queue, { () -> Void in
            let fileToDelete = file
            var files = NSMutableSet(set: folder.files)
            files.removeObject(file)
            folder.files = files
            self.context.deleteObject(fileToDelete)
            self.save()
        })
        dispatch_barrier_async(queue, { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completed()
            })
        })
    }
    
}
