//
//  UserMessageHandler.swift
//  nCRYPT
//
//  Created by Kartik on 10/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import Foundation

class UserMessageHandler{
    
    private var _messages = [String]()
    private var _keys = [String]()
    
    init(messages: [String], keys: [String]) {
        _messages = messages
        _keys = keys
    }
    
    var messages: [String]{
        return _messages
    }
    
    var keys: [String]{
        return _keys
    }
    
    
}
