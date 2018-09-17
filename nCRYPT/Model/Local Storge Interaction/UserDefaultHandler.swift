
//
//  UserDefaultHndler.swift
//  nCRYPT
//
//  Created by Kartik on 15/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import Foundation

class UserDefaultHandler{
    
    static private var _instance = UserDefaultHandler()
    
    static var Instance: UserDefaultHandler{
        return _instance
    }
    
    let USER_NAME = "USER_NAME"
    let USER_EMAIL = "USER_EMAIL"
    let USER_IMAGE_URL = "USER_IMAGE_URL"
    let USER_ID = "USER_ID"
    
    func setTheName(userName: String){
        UserDefaults.standard.removeObject(forKey: USER_NAME)
        UserDefaults.standard.set(userName, forKey: USER_NAME)
        UserDefaults.standard.synchronize()
        
    }
    
    func setTheEmail(email: String){
        
        UserDefaults.standard.set(email, forKey: USER_EMAIL)
        UserDefaults.standard.synchronize()
        
    }
    
    func setImageUrl(imageUrl: String){
        
        UserDefaults.standard.set(imageUrl, forKey: USER_IMAGE_URL)
        UserDefaults.standard.synchronize()
        
    }
    
    func setCurrentUserId(userId: String){
        UserDefaults.standard.set(userId, forKey: USER_ID)
    }
    
    func currentUserName() -> String{
        return (UserDefaults.standard.string(forKey: USER_NAME)!)
    }
    
    func currentUserEmail() -> String{
        return (UserDefaults.standard.string(forKey: USER_EMAIL)!)
    }
    
    func currentUserImageUrl() -> String{
        return (UserDefaults.standard.string(forKey: USER_IMAGE_URL)!)
    }
    
    func getTheMessageFlag(senderUserId: String) -> Int{
        return UserDefaults.standard.integer(forKey: senderUserId)
    }
    
    func currentUserId() -> String{
        return (UserDefaults.standard.string(forKey: USER_ID)!)
    }
}

