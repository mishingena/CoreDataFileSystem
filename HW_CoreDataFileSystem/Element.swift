//
//  Element.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 12.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

enum FileType {
    case Folder
    case TextFile
    case ImageFile
}

class Element: NSObject {
   
    var fileType: FileType!
    var folder: Folder?
    var textFile: TextFile?
    var imageFile: ImageFile?
    
    init(type: FileType, name: String) {
        self.fileType = type
        switch type {
        case .Folder:
            folder = Folder()
            folder?.name = name
        case .TextFile:
            textFile = TextFile()
            textFile?.name = name
            textFile?.text = ""
        case .ImageFile:
            imageFile = ImageFile()
            imageFile?.name = name
        }
    }
    
    init(folder: Folder) {
        self.fileType = .Folder
        self.folder = folder
    }
    
    init(imageFile: ImageFile) {
        self.fileType = .ImageFile
        self.imageFile = imageFile
    }
    
    init(textFile: TextFile) {
        self.fileType = .TextFile
        self.textFile = textFile
    }
    
    func getObject() -> AnyObject {
        switch self.fileType! {
        case .Folder: return self.folder!
        case .TextFile: return self.textFile!
        case .ImageFile: return self.imageFile!
        }
    }
}
