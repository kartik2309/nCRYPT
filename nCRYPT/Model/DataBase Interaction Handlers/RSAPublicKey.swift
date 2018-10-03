//
//  RSAPublicKey.swift
//  nCRYPT
//
//  Created by Kartik on 30/09/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import Foundation

class RSAPublicKey{
    
    private var _publicKey: String
    
    init(publicKey: String) {
        _publicKey = publicKey
    }
    
    var publicKey: String{
        return _publicKey
    }
}
