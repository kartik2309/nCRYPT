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
    
    init(messages: [String]) {
        _messages = messages
    }
    
    var messages: [String]{
        return _messages
    }
    
    
}
