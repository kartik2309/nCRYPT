//
//  SecurityFrameWork.swift
//  nCRYPT
//
//  Created by Kartik on 08/07/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import Foundation
import Security
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

    //MARK: Encoding Functions
    func stringToData(input: String) -> Data?{
        
        guard let data = input.data(using: .utf8, allowLossyConversion: false)
            else{
                print("could not convert string to data")
                return nil
        }
        return data
    }
    
    func base64StringToData(input: String)-> Data?{
        let data = Data(base64Encoded: input)
        return data
    }
    
    func dataToString(input: Data) -> String?{
        
        let b64String = dataToBase64String(input: input)
        let string = base64StringToString(input: b64String!)
        
        return string
    }
    
    func dataToBase64String(input: Data) -> String?{
        return input.base64EncodedString()
    }
    
    func base64StringToString(input: String)-> String?{
        let data = Data(base64Encoded: input)
        let string = String(decoding: data!, as: UTF8.self)
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
    
    
    //MARK: Password based key dervivation function
    func pdkf2sha512(password: String) -> Data? {
        
        let salt = password.data(using: .utf8, allowLossyConversion: true)
        
        let keyData = pbkdf2(hash: CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512), password: password, salt: salt!, keyByteCount: 32, rounds: 9973)
        
        return keyData
    }
    
    private func pbkdf2(hash :CCPBKDFAlgorithm, password: String, salt: Data, keyByteCount: Int, rounds: Int) -> Data? {
        let passwordData = password.data(using:String.Encoding.utf8)!
        var derivedKeyData = Data(repeating:0, count:keyByteCount)
        var derivedKeyDataCopy = derivedKeyData
        
        let derivationStatus = derivedKeyDataCopy.withUnsafeMutableBytes {derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    password, passwordData.count,
                    saltBytes, salt.count,
                    hash,
                    UInt32(rounds),
                    derivedKeyBytes, derivedKeyData.count)
            }
        }
        if (derivationStatus != 0) {
            print("Error: \(derivationStatus)")
            return nil;
        }
        
        return derivedKeyData
    }
    
    //MARK: RSA
    func rsaEncryption(message: String, publicKeyPEM: String) throws -> String{
        
        let publicKey = try PublicKey(pemEncoded: publicKeyPEM)
        let clear = try ClearMessage(string: message, using: .utf8)
        let encrypted = try clear.encrypted(with: publicKey, padding: .OAEP)
        
        let base64String = encrypted.base64String
        return base64String
        
    }
    
    func rsaDecryption(message: String, userId: String) throws -> String{
        
        let privateKey = try PrivateKey(pemEncoded: rsaPrivateKey(userId: userId))
        let encrypted = try EncryptedMessage(base64Encoded: message)
        let clear = try encrypted.decrypted(with: privateKey, padding: .OAEP)
        
        let string = try clear.string(encoding: .utf8)
        return string
    }
    
    func rsaPrivateKey(userId: String)->String{
        return KeychainWrapper.standard.string(forKey: "private" + userId)!
    }
    
    func rsaPublicKey(userId: String)->String{
        return KeychainWrapper.standard.string(forKey: "public" + userId)!
    }
    
    func rsaKeyGeneration(userId: String) throws -> Bool{
        
        var success = false
        let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
        let privateKey = keyPair.privateKey
        let publicKey = keyPair.publicKey
        
        let privateKeyPEM = try privateKey.pemString()
        let publicKeyPEM = try publicKey.pemString()

        
        let prks = KeychainWrapper.standard.set(privateKeyPEM, forKey: "private" + userId)
        let puks = KeychainWrapper.standard.set(publicKeyPEM, forKey: "public" + userId)
        
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
        
        return cryptData
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
    
}
