//
//  FormattingHelper.swift
//  HW_CoreDataFileSystem
//
//  Created by Гена on 15.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit
import Foundation

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

class FormattingHelper: NSObject {
   
    class func getFormattedSizeFromByteSize(sizeInBytes: Int) -> String {
        let sizeInBytes = Double(sizeInBytes)
        var someFormat = ".0"
        
        if sizeInBytes < 512.0 {
            return "\(sizeInBytes.format(someFormat)) байт"
        }
        
        let sizeInKBytes = self.getKByteFromByte(sizeInBytes)
        someFormat = ".1"
        if sizeInKBytes < 512.0 {
            return "\(sizeInKBytes.format(someFormat)) КБайт"
        }
        
        let sizeInMBytes = self.getMByteFromKByte(sizeInKBytes)
        someFormat = ".2"
        if sizeInMBytes < 512.0 {
            return "\(sizeInMBytes.format(someFormat)) МБайт"
        }
        
        let sizeInGBytes = self.getGByteFromMByte(sizeInMBytes)
        if sizeInGBytes < 512 {
            return "\(sizeInGBytes.format(someFormat)) ГБайт"
        } else {
            return "100500"
        }
    }
    
    private class func getKByteFromByte(byte: Double) -> Double {
        return byte / 1024.0
    }
    
    private class func getMByteFromKByte(kByte: Double) -> Double {
        return kByte / 1024.0
    }
    
    private class func getGByteFromMByte(mByte: Double) -> Double {
        return mByte / 1024.0
    }
    
}
