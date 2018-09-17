//
//  SearchHandler.swift
//  nCRYPT
//
//  Created by Kartik on 22/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import Foundation

class SearchHandlerToAddChat{
    
    private var _name: String
    private var _email: String
    private var _imageUrl: String
    private var _userId: String
    
    init(name: String, email: String, imageUrl: String, userId: String) {
        _name = name
        _email = email
        _imageUrl = imageUrl
        _userId = userId
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
    
    var userId: String{
        return _userId
    }
     
}
