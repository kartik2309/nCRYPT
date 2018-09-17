//
//  FileManagerHandler.swift
//  nCRYPT
//
//  Created by Kartik on 17/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import UIKit
import SwiftyRSA

protocol FetchMessageHistoryFromLocal:class {
    func recieveMessageContent(messageHistory: String)
}

class FileManagerHandler{
    
    static private var _instance = FileManagerHandler()
    
    static var Instance: FileManagerHandler{
        return _instance
    }
    
    
    weak var messageHistoryDelegate: FetchMessageHistoryFromLocal?
    
    func saveImage(image: UIImage, imageName: String) -> Bool {
        guard let data = UIImageJPEGRepresentation(image, 1) ?? UIImagePNGRepresentation(image) else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            
            try data.write(to: directory.appendingPathComponent(imageName + ".jpeg")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named + ".jpeg").path)
        }
        return nil
    }
    
    func saveChatLog(senderId: String, senderUserId: String, message: String, senderAtTheMoment: String){
        
        let fileName = senderId + senderUserId + ".txt"
        
        let messageTextToAdd = senderAtTheMoment + "-" + message + "`"
        
        let textData = messageTextToAdd.data(using: .utf8, allowLossyConversion: false)
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let url = NSURL(fileURLWithPath: path!)
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            if FileManager.default.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                
                let fileHandle = FileHandle(forWritingAtPath: filePath)
                fileHandle?.seekToEndOfFile()
                fileHandle?.write(textData!)
                fileHandle?.closeFile()
                
            } else {
                print("FILE NOT AVAILABLE")
                
                let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let filePath = directory?.appendingPathComponent(fileName)
                
                print(filePath as Any)
                
                do {
                    try messageTextToAdd.write(to: filePath!, atomically: false, encoding: .utf8)
                }
                catch {
                    print("Error Occured")
                }

            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
    }
    
    func loadChatLog(senderId: String, senderUserId: String){
        
        let fileName = senderId + senderUserId + ".txt"
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let url = NSURL(fileURLWithPath: path!)
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                
                do{
                    let content = try String(contentsOfFile: filePath, encoding: .utf8)
                    messageHistoryDelegate?.recieveMessageContent(messageHistory: content)
                    
                }
                catch{
                    print("Error occured in reading")
                }
                
            } else {
                messageHistoryDelegate?.recieveMessageContent(messageHistory: "")
                print("FILE NOT AVAILABLE")
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
    }
    
    func userIsSigningOut(){
        let documentsUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        do{
            let fileUrls = try FileManager.default.contentsOfDirectory(at: documentsUrls!, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles,.skipsPackageDescendants])
            
            for fileUrl in fileUrls {
                if fileUrl.pathExtension == "txt" || fileUrl.pathExtension == "jpeg"{
                    try FileManager.default.removeItem(at: fileUrl)
                    print("deleted")
                }
            }
        }catch{
            print("Error in deleting files")
        }
    }
    
    func userSwippedToDeleteMessages(senderId: String, senderUserId: String){
        let fileName = senderId + senderUserId + ".txt"
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let url = NSURL(fileURLWithPath: path!)
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                
                do{
                    try FileManager.default.removeItem(atPath: filePath)
                }
                catch{
                    print("Error occured in reading")
                }
                
            } else {
                print("FILE NOT AVAILABLE")
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
    }
}


