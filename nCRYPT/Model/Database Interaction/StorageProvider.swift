//
//  StorageProvider.swift
//  nCRYPT
//
//  Created by Kartik on 08/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import Foundation
import Firebase

typealias StorageHandler = (_ msg: String?) -> Void

private struct StorageReferencePath{
    static let USER_PROFILE_IMAGES = "User Profile Images"
}

private struct StorageErrorHandlerCodes{
    static let USER_UNAUTHENTICATED = "User is unauthenticated. Authenticate and try again."
    static let NON_MATCHING_CHECKSUM = "File on the client does not match the checksum of the file received by the server. Try uploading again."
    static let CANCELLED = "User cancelled the operation."
    static let UNKNOWN_ERROR = "An unknown error occurred."
    static let PROBLEM_CONNECTING = "An error occurred while performing the request. Please Check your Internet Connection"
}

class StorageProvider{
    
    static private var _instance = StorageProvider()
    
    static var Instance: StorageProvider{
        return _instance
    }
    
    var storageReference: StorageReference{
        return Storage.storage().reference()
    }
    
    var storageReferenceToUserImage: StorageReference{
        return storageReference.child(StorageReferencePath.USER_PROFILE_IMAGES)
    }
    
    func saveTheUser(userId: String, email: String,fullName: String, userImage: UIImage, storageHandler: StorageHandler?){
        
        let userImageName = NSUUID().uuidString
        let userImageStorage = storageReferenceToUserImage.child(userImageName)
        
        if let userImageData = UIImageJPEGRepresentation(userImage, 0.2){
            
            userImageStorage.putData(userImageData, metadata: nil, completion: {
                (metadata, error) in
                
                if error != nil{
                    self.storageErrorHandler(error: error! as NSError, storageHandler: storageHandler!)
                }
                
                else{
                    userImageStorage.downloadURL(completion: {
                        (url, error) in
                        if let downloadUrl = url?.absoluteString{
                            
                            if(FileManagerHandler.Instance.saveImage(image: userImage, imageName: userId + "userImage")){
                                print("Success")
                            }
                            
                            UserDefaultHandler.Instance.setTheName(userName: fullName)
                            UserDefaultHandler.Instance.setTheEmail(email: email)
                            UserDefaultHandler.Instance.setImageUrl(imageUrl: downloadUrl)
                            UserDefaultHandler.Instance.setCurrentUserId(userId: userId)
                            
                            DatabaseProvider.Instance.saveUserDataToDataBase(userId: userId, email: email, fullName: fullName, imageUrl: downloadUrl)
                            
                        }
                    })
                }
            })
        }
    }
    
    func downloadUserImage(cell: ChatCollectionViewCell, url: String, userId: String){
        
        
        if FileManagerHandler.Instance.getSavedImage(named: userId) != nil{
            cell.userImage.image = FileManagerHandler.Instance.getSavedImage(named: userId)
        }
        else{
            let userImageData = Storage.storage().reference(forURL: url)
            
            userImageData.getData(maxSize: 10*5000*5000, completion: {
                
                (data, error) in
                
                if error != nil{
                    print(error as Any)
                }
                else{
                    let image = UIImage(data: data!)
                    cell.userImage.image = image
                    if(FileManagerHandler.Instance.saveImage(image: image!, imageName: userId)){
                        print("saved")
                    }
                    
                }
            })
        }
        
        
    }
    
    func downloadUserImage(cell: AddChatCollectionViewCell, url: String){
        
        let userImageData = Storage.storage().reference(forURL: url)
        
        userImageData.getData(maxSize: 10*5000*5000, completion: {
            
            (data, error) in
            
            if error != nil{
                print(error as Any)
            }
            else{
                let image = UIImage(data: data!)
                cell.userImage.image = image
                
            }
        })
        
        
    }
    
    
    func downloadCurrentUserImage(url: String, imageName: String){
        
        
        if FileManagerHandler.Instance.getSavedImage(named: imageName) != nil{
            print("already exists")
        }
        
        else{
            print("newsave")
            let userImageData = Storage.storage().reference(forURL: url)
            
            userImageData.getData(maxSize: 10*5000*5000, completion: {
                
                (data, error) in
                
                if error != nil{
                    print(error as Any)
                }
                else{
                    if data != nil{
                        let imageData = UIImageJPEGRepresentation(UIImage(data: data!)!, 1)
                        
                        let image = UIImage(data: imageData!)
                        if(FileManagerHandler.Instance.saveImage(image: image!, imageName: imageName)){
                            print("success in saving user Image")
                        }
                        else{
                            print("save failed for user Image")
                        }
                        
                    }
                    
                }
            })
        }
        
    }
    
    //MARK: Private Function
    
  
    
    private func storageErrorHandler(error: NSError, storageHandler: StorageHandler){
        
        if let errorCode = StorageErrorCode(rawValue: error.code){
            
            switch errorCode{
                
            case .unauthenticated:
                storageHandler(StorageErrorHandlerCodes.USER_UNAUTHENTICATED)
                break
                
            case .nonMatchingChecksum:
                storageHandler(StorageErrorHandlerCodes.NON_MATCHING_CHECKSUM)
                break
                
            case .cancelled:
                storageHandler(StorageErrorHandlerCodes.CANCELLED)
                break
                
            case.unknown:
                storageHandler(StorageErrorHandlerCodes.UNKNOWN_ERROR)
                
            default:
                storageHandler(StorageErrorHandlerCodes.PROBLEM_CONNECTING)
                
            }
        }
    }
    
}
