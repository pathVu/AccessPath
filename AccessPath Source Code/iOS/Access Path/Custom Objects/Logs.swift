//
//  Logs.swift
//  LogsFile
//
//  Created by ChetuMac-007 on 07/12/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import Foundation


class Logs: NSObject {
    
//   class func writeLog(value:String) {
//
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let url = NSURL(fileURLWithPath: path)
//        if let pathComponent = url.appendingPathComponent("Logs.txt") {
//            let filePath = pathComponent.path
//            let fileManager = FileManager.default
//            if fileManager.fileExists(atPath: filePath) {
//                print("FILE AVAILABLE")
//                //writing
//                do {
//                    try  value.write(toFile: filePath, atomically: true, encoding: .utf8)
//                    //value.write(to: filePath, atomically: false, encoding: .utf8)
//                }
//                catch {/* error handling here */}
//            } else {
//                print("FILE NOT AVAILABLE")
//                fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
//
//                //writing
//                do {
//                    try  value.write(toFile: filePath, atomically: true, encoding: .utf8)
//                    //value.write(to: filePath, atomically: false, encoding: .utf8)
//                }
//                catch {/* error handling here */}
//            }
//        } else {
//            print("FILE PATH NOT AVAILABLE")
//        }
//    }
    
    class func writeLog(value:String) {
        let  strValue = "\n" + value
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let data = strValue.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let fileManager = FileManager.default
        if let pathComponent = url.appendingPathComponent("Logs.txt") {
            let filePath = pathComponent.path
            if fileManager.fileExists(atPath: filePath) {
                self.writeAtPath(data: data, path: filePath)
            }
            else {
                // Create the file and write on this
                fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
                self.writeAtPath(data: data, path: filePath)
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
    }
    //Write the text on the Log file
   class func writeAtPath(data:Data, path:String) {
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        }
        else {
            
        }
    }
    func removeFile()  {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let fileManager = FileManager.default
        if let pathComponent = url.appendingPathComponent("Logs.txt"){
        let filePath = pathComponent.path
        if fileManager.fileExists(atPath: filePath) {
            //self.writeAtPath(data: data, path: filePath)
            
        }
        }
    }
}

