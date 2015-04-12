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

//enum Element {
//    case TypeFolder(Folder)
//    case TypeTextFile(TextFile)
//    case TypeImageFile(ImageFile)
//}


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
    
    func getRootFolder(completion:(Folder) -> ()) {
        dispatch_async(queue, { () -> Void in
            var error: NSError?
            let request = NSFetchRequest(entityName: "Folder")
            var results = self.context.executeFetchRequest(request, error: &error)
            println(results?.count)
            
//            assert(results?.count < 2, "Error, more than one root folder")
            
            if let error = error {
                abort()
            }
            
            if let result = results?.first as? Folder {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(result as Folder)
                })
            } else {
                let result = Folder()
                result.name = "Root"
                self.save()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(result)
                })
            }
        })
    }
    
    func getElementsFromFolder(folder: Folder, completion: ([Element]) -> ()) {
        dispatch_async(queue, { () -> Void in
            var elements = [Element]()
            
            for image in folder.imageFiles {
                elements.append(Element(imageFile: image as! ImageFile))
            }
            
            for textFile in folder.textFiles {
                elements.append(Element(textFile: textFile as! TextFile))
            }
            
            for fol in folder.folders {
                elements.append(Element(folder: fol as! Folder))
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(elements)
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
    
}
