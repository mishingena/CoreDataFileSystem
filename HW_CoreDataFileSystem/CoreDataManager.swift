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

enum ActionType {
    case Add
    case Rename
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
    
    //MARK: - Class functions
    
    class func getSortedFilesFromFolder(folder: FileFolder) -> [File] {
        var array = folder.files.allObjects as! [File]
        array.sort { (firstFile: File, secondFile:File) -> Bool in
            return (firstFile.creationDate.compare(secondFile.creationDate) == NSComparisonResult.OrderedAscending ? true : false)
        }
        //also calculate size
        for object in folder.files {
            var file = object as! File
            var total = 0;
            file.size = self.getSizeOfFile(file, total: &total)
        }
        return array
    }
    
    class func moveFileFromAllFiles(inout allFiles: [File], fromIndex: Int, toIndex: Int) {
        let file = allFiles[fromIndex]
        allFiles.removeAtIndex(fromIndex)
        allFiles.insert(file, atIndex: toIndex)
        
        for file in allFiles {
            file.creationDate = NSDate()
        }
        CoreDataManager.sharedInstance.save()
    }
    
    class func getSizeOfFile(file: File,inout total: Int) -> Int {
        switch file.getFileType()! {
        case .TextFile:
            let file = file as! FileText
            total += file.getSize()
        case .ImageFile:
            let file = file as! FileImage
            total += file.getSize()
        case .Folder:
            let folder = file as! FileFolder
            for file in folder.files {
                self.getSizeOfFile(file as! File, total: &total)
            }
        }
        return total
    }
}
