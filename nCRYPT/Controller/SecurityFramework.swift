//
//  SecurityFrameWork.swift
//  nCRYPT
//
//  Created by Kartik on 08/07/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import Foundation
import Security
import CryptoSwift
import SwiftyRSA
import SwiftKeychainWrapper

class SecurityFramework{
    
    static private var _security = SecurityFramework()
    
    static var security: SecurityFramework{
        return _security
    }
    
    enum AESerror: Error{
        case KeyError((String,Int))
        case IVError((String,Int))
        case CryptorError((String,Int))
        
    }
    
    func keyderivation(string: String) -> String{
        return string.sha256().md5()
    }
    
    
    func stringToData(input: String) -> Data?{
        guard let data = input.data(using: .utf8, allowLossyConversion: false)
            else{
                print("could not convert string to data")
                return nil
        }
        return data
    }
    
    func datatoString(input: Data) -> String?{
        guard let string = String(data: input, encoding: .utf8)
            else {
                print("Could not convert the data to string")
                return nil
        }
        return string
    }
    
    //MARK: Hashing
    func sha512(data: Data) -> Data?{
        var digestData = Data(count: Int(CC_SHA512_BLOCK_BYTES))
        
        _ = digestData.withUnsafeMutableBytes{ digestBytes in
            data.withUnsafeBytes{ messageBytes in
                CC_SHA512(messageBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return digestData
    }
    
    //MARK: RSA
    func rsaEncryption(message: String, publicKeyPEM: String) throws -> String{
        
        let publicKey = try PublicKey(pemEncoded: publicKeyPEM)
        let clear = try ClearMessage(string: message, using: .utf8)
        let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1SHA512)
        
        let base64String = encrypted.base64String
        return base64String
        
    }
    
    func rsaDecryption(message: String) throws -> String{
        
        let privateKey = try PrivateKey(pemEncoded: rsaPrivateKey())
        let encrypted = try EncryptedMessage(base64Encoded: message)
        let clear = try encrypted.decrypted(with: privateKey, padding: .PKCS1SHA512)
        
        let base64String = clear.base64String
        return base64String
    }
    
    func rsaPrivateKey()->String{
        return KeychainWrapper.standard.string(forKey: "private")!
    }
    
    func rsaPublicKey()->String{
        return KeychainWrapper.standard.string(forKey: "public")!
    }
    
    func rsaKeyGeneration() throws -> Bool{
        
        var success = false
        let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
        let privateKey = keyPair.privateKey
        let publicKey = keyPair.publicKey
        
        let privateKeyPEM = try privateKey.pemString()
        let publicKeyPEM = try publicKey.pemString()

        let prks = KeychainWrapper.standard.set(privateKeyPEM, forKey: "private")
        let puks = KeychainWrapper.standard.set(publicKeyPEM, forKey: "public")
        
        if (puks && prks){
            success = true
        }
        
        return success
    }
    
    
    //MARK: AES
    func aesKeyGeneration() -> String{
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*(){}[];:'<,>.?/|_-+="
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< 32 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    
    func aes256Encryption(data: Data, keyData: Data) throws -> Data {
        if keyData.count != kCCKeySizeAES256 {
            throw AESerror.KeyError(("Invalid Key Length", keyData.count))
        }
        
        let ivSize = kCCBlockSizeAES128
        let cryptLength = size_t(ivSize+data.count+kCCBlockSizeAES128)
        
        var cryptData = Data(count: cryptLength)
        
        let status = cryptData.withUnsafeMutableBytes { ivBytes in
            SecRandomCopyBytes(kSecRandomDefault, kCCBlockSizeAES128, ivBytes)
        }
        
        if status != 0{
            throw AESerror.IVError(("IV Operation Failed", Int(status)))
        }
        
        var numBytesEncrypted: size_t = 0
        let options = CCOptions(kCCOptionPKCS7Padding)
        
        let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes{ dataBytes in
                keyData.withUnsafeBytes{ keyBytes in
                    CCCrypt(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmAES), options, keyBytes, keyData.count, cryptBytes, dataBytes, data.count, cryptBytes+kCCBlockSizeAES128, cryptLength, &numBytesEncrypted)
                }
            }
        }
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.count = numBytesEncrypted + ivSize
        }
        else {
            throw AESerror.CryptorError(("Encryption failed", Int(cryptStatus)))
        }
        
        return cryptData;
    }
    
    func aes256Decryption(data:Data, keyData:Data) throws -> Data? {
        let keyLength = keyData.count
        let validKeyLengths = [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256]
        if (validKeyLengths.contains(keyLength) == false) {
            throw AESerror.KeyError(("Invalid key length", keyLength))
        }
        
        let ivSize = kCCBlockSizeAES128;
        let clearLength = size_t(data.count - ivSize)
        var clearData = Data(count:clearLength)
        
        var numBytesDecrypted :size_t = 0
        let options   = CCOptions(kCCOptionPKCS7Padding)
        
        let cryptStatus = clearData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes {dataBytes in
                keyData.withUnsafeBytes {keyBytes in
                    CCCrypt(CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES128),
                            options,
                            keyBytes, keyLength,
                            dataBytes,
                            dataBytes+kCCBlockSizeAES128, clearLength,
                            cryptBytes, clearLength,
                            &numBytesDecrypted)
                }
            }
        }
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            clearData.count = numBytesDecrypted
        }
        else {
            throw AESerror.CryptorError(("Decryption failed", Int(cryptStatus)))
        }
        
        return clearData;
    }
    
    //MARK: Key Chain
    func saveIntoKeyChain(data: String,key: String){
        KeychainWrapper.standard.set(data, forKey: key)
    }
    
    func readFromKeyChain(key: String) -> String{
        return KeychainWrapper.standard.string(forKey: key)!
    }
    
    //MARK: Key Sharing

    
    func KeySharingReceive(aesKey: String) throws -> String{
        let decryptedKey = try rsaDecryption(message: aesKey)
        return decryptedKey
    }
    
}

