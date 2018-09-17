//
//  MessageHandler.swift
//  nCRYPT
//
//  Created by Kartik on 09/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import Foundation


class MessageSenderHandler{
   
    private var _userId: String
    private var _name: String
    private var _email: String
    private var _imageUrl: String
    
    init(userId: String,name: String, email: String, imageUrl: String) {
        _userId = userId
        _name = name
        _email = email
        _imageUrl = imageUrl

    }
    
    var userId: String{
        return _userId
    }
    
    var name: String{
        return _name
    }
    
    var email: String{
        return _email
    }
    
    var imageUrl: String{
        return _imageUrl
    }
    
}
