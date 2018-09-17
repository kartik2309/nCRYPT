//
//  DatabaseProvider.swift
//  nCRYPT
//
//  Created by Kartik on 08/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import Foundation
import Firebase
import SwiftyRSA


private struct DataBaseReferencePaths{
    static let USER_DATA = "User Data"
    static let USER_CONTACTS = "User Contacts"
    static let USER_MESSAGES = "User Messages"
    static let EMAIL = "Email"
    static let FULL_NAME = "Full Name"
    static let IMAGE_URL = "Image Url"
    static let MESSAGE = "Messages"
    static let RSA = "RSA"
    static let AESKEY = "AES Key"
}

protocol FetchMessagesSenderDetails: class {
    func messageSenderData(senderOfMessages: [MessageSenderHandler])
    
    }

protocol  FetchMessageText: class {
    func messagesText(message: [UserMessageHandler])
}

protocol FetchMessageInRealTime: class {
    func recieveMessagesInRealTime(messages: [String])
}

protocol FetchUser: class{
    func getUserDetails(searchResultDetails: [SearchHandlerToAddChat])
}

class DatabaseProvider{
    
    static private var _instance = DatabaseProvider()
    
    static var Instance: DatabaseProvider{
        return _instance
    }
    
    weak var messageDelegate: FetchMessagesSenderDetails?
    weak var messageTextDelegate: FetchMessageText?
    weak var messageInRealTimeDelegate: FetchMessageInRealTime?
    weak var searchResultsDelegate: FetchUser?
    
    var databaseReference: DatabaseReference{
        return Database.database().reference()
    }
    
    
    func userDataFromDataBase() {
        print("userNameFromDataBase is being called"); databaseReference.child(AuthenticationProvider.Instance.userId()).child(DataBaseReferencePaths.USER_DATA).observeSingleEvent(of: .value, with: {
            (snapshot: DataSnapshot) in
            print(snapshot)
            if snapshot.exists(){
                print("snapshot exists")
                for child in snapshot.children{
                    
                    let userData = child as! DataSnapshot
                    
                    if userData.key == DataBaseReferencePaths.FULL_NAME{
                        UserDefaultHandler.Instance.setTheName(userName: userData.value as! String)
                        print("name:",userData)
                    }
                    
                    else if userData.key == DataBaseReferencePaths.EMAIL{
                        UserDefaultHandler.Instance.setTheEmail(email: userData.value as! String)
                        
                    }
                    
                    else if userData.key == DataBaseReferencePaths.IMAGE_URL{
                        let uid = AuthenticationProvider.Instance.userId()
                        UserDefaultHandler.Instance.setImageUrl(imageUrl: userData.value as! String)
                        
                        StorageProvider.Instance.downloadCurrentUserImage(url: userData.value as! String, imageName: uid + "userImage")
                        
                    }
                }
            }
            else{
                print("recurcive calling")
                self.userDataFromDataBase()
            }
        
        })
        
    }
    
    func saveUserDataToDataBase(userId: String, email: String, fullName: String, imageUrl: String){
        
        let data: Dictionary<String, Any> = [DataBaseReferencePaths.EMAIL: email, DataBaseReferencePaths.FULL_NAME: fullName, DataBaseReferencePaths.IMAGE_URL: imageUrl]
        print("Saving to db")
        databaseReference.child(userId).child(DataBaseReferencePaths.USER_DATA).setValue(data)
        
        
        do{
            if(try SecurityFramework.security.rsaKeyGeneration()){
                let rsaKeyDictionary: Dictionary<String,String> = [DataBaseReferencePaths.RSA: SecurityFramework.security.rsaPublicKey()]
                databaseReference.child(userId).child(DataBaseReferencePaths.RSA).setValue(rsaKeyDictionary)

            }
            
        }
        catch{
            print("Error Occured in key generation:",error)
        }
        
    }
    
    
    func getMessageSenderDetails(){
        
        databaseReference.child(UserDefaultHandler.Instance.currentUserId()).child(DataBaseReferencePaths.USER_MESSAGES).observeSingleEvent(of: .value, with: {
            
            (snapshot: DataSnapshot) in
            
            var senderOfMessages = [MessageSenderHandler]()
            
            if snapshot.exists(){
                
                for child in snapshot.children{
                    
                    let childSender = child as! DataSnapshot
                    
                    let key = childSender.key
                    
                    
                    if let senderDetails = childSender.value as? NSDictionary{
                        
                        if let fullName = senderDetails[DataBaseReferencePaths.FULL_NAME] as? String, let email = senderDetails[DataBaseReferencePaths.EMAIL] as? String, let imageUrl = senderDetails[DataBaseReferencePaths.IMAGE_URL] as? String{
                            
                            let userDetailOfMessage = MessageSenderHandler(userId: key, name: fullName, email: email, imageUrl: imageUrl)
                            
                            senderOfMessages.append(userDetailOfMessage)
                            
                        }
                        
                        
                    }
                    
                }
                self.messageDelegate?.messageSenderData(senderOfMessages: senderOfMessages)
            }
            else{
                senderOfMessages.removeAll()
                self.messageDelegate?.messageSenderData(senderOfMessages: senderOfMessages)
            }
            
            
        })
        
    }
    
    func getMessages(){
        
        databaseReference.child(UserDefaultHandler.Instance.currentUserId()).child(DataBaseReferencePaths.USER_MESSAGES).queryLimited(toLast: 50).observeSingleEvent(of: DataEventType.value, with: {
            
            (snapshot: DataSnapshot) in
            
            var messageTextArray = [UserMessageHandler]()
            var messages = [String]()
            
            if snapshot.exists(){
                
                for child1 in snapshot.children{
                    
                    messages.removeAll()
                    
                    let childSender = child1 as! DataSnapshot
                    
                    for child2 in childSender.children{
                        
                        let childMessage = child2 as! DataSnapshot
                        
                        for child3 in childMessage.children{
                            
                            let childMessageText = child3 as! DataSnapshot
                            
                            messages.append(childMessageText.value as! String)
                            
                        }
                    }
                    let newMessage = UserMessageHandler(messages: messages)
                    messageTextArray.append(newMessage)
                    self.messageTextDelegate?.messagesText(message: messageTextArray)
                }
            }
            else{
                messageTextArray.removeAll()
                self.messageTextDelegate?.messagesText(message: messageTextArray)
            }
        })
    }

    func sendMessageToDatabase(senderUserId: String,senderName: String, senderEmail:String, senderImageUrl: String, senderId: String, message: String){
        
        let key = self.databaseReference.child(senderUserId).child(DataBaseReferencePaths.USER_MESSAGES).child(senderId).child(DataBaseReferencePaths.MESSAGE).childByAutoId().key
        databaseReference.child(senderUserId).child(DataBaseReferencePaths.USER_MESSAGES).child(senderId).observeSingleEvent(of: DataEventType.value, with: {
            
            (snapshot: DataSnapshot) in
            

            if snapshot.exists() {
                
                let messageDict: Dictionary<String, Any> = [key!: message]
                
                self.databaseReference.child(senderUserId).child(DataBaseReferencePaths.USER_MESSAGES).child(senderId).child(DataBaseReferencePaths.MESSAGE).updateChildValues(messageDict)
 
            }
            else{

                let data: Dictionary<String, Any> = [DataBaseReferencePaths.EMAIL: senderEmail, DataBaseReferencePaths.FULL_NAME: senderName, DataBaseReferencePaths.IMAGE_URL: senderImageUrl]
                
                self.databaseReference.child(senderUserId).child(DataBaseReferencePaths.USER_MESSAGES).child(senderId).setValue(data)
                
                let messageDict: Dictionary<String, Any> = [key: message]
                
                self.databaseReference.child(senderUserId).child(DataBaseReferencePaths.USER_MESSAGES).child(senderId).child(DataBaseReferencePaths.MESSAGE).updateChildValues(messageDict)
                
            }

        })
        
     
    }
    
    func removeMessages(senderId: String, senderUserId: String){
        databaseReference.child(senderId).child(DataBaseReferencePaths.USER_MESSAGES).child(senderUserId).child(DataBaseReferencePaths.MESSAGE).removeValue()
    }
    
    func deliverMessagesDirectlyToMessageView(senderId: String, senderUserId: String, flag: Bool){
        
        if flag {
            databaseReference.child(senderId).child(DataBaseReferencePaths.USER_MESSAGES).child(senderUserId).child(DataBaseReferencePaths.MESSAGE).observeSingleEvent(of: .value) {
                (snapshot: DataSnapshot) in
                
                var realTimeMessagesInChat = [String]()
                
                if snapshot.exists(){
                    
                    for child in snapshot.children{
                        
                        let messageText = child as! DataSnapshot
                        
                        realTimeMessagesInChat.append(messageText.value as! String)
                        
                        
                    }
                    
                    self.messageInRealTimeDelegate?.recieveMessagesInRealTime(messages: realTimeMessagesInChat)
                    DatabaseProvider.Instance.removeMessages(senderId: senderId, senderUserId: senderUserId)
                    
                }
                
            }
        }
    }
  
    func searchForUsers(searchText: String){
        
        databaseReference.queryOrdered(byChild: "User Data/Full Name").queryStarting(atValue: searchText, childKey: "Full Name").queryEnding(atValue: searchText + "\u{f8ff}", childKey: "FullName").observeSingleEvent(of: .value, with: {
            
            (snapshot: DataSnapshot) in
            
            var searchDetailsResult = [SearchHandlerToAddChat]()
            let currentUserName = UserDefaultHandler.Instance.currentUserName()
            
            for child in snapshot.children{

                let newChild = child as! DataSnapshot
                let userId = newChild.key
                
                for child1 in newChild.children{
                    
                    let userData = child1 as! DataSnapshot
                    let key = userData.key
                    
                    if key == DataBaseReferencePaths.USER_DATA{
                        let userDetailsDictionary = userData.value as? NSDictionary
                            
                        let email = userDetailsDictionary![DataBaseReferencePaths.EMAIL] as! String
                        let ImageUrl = userDetailsDictionary![DataBaseReferencePaths.IMAGE_URL] as! String
                        let name = userDetailsDictionary![DataBaseReferencePaths.FULL_NAME] as! String
                        
                        if name.range(of: searchText) != nil && name != currentUserName {
                            
                            let newResult = SearchHandlerToAddChat(name: name, email: email, imageUrl: ImageUrl, userId: userId)
                            
                            searchDetailsResult.append(newResult)
                        }
                        
                    }
                }

            }
            self.searchResultsDelegate?.getUserDetails(searchResultDetails: searchDetailsResult)
        })
        
    }
    
    func saveNewChat(senderUserId: String, senderUserName: String, senderUserEmail: String, senderUserImageUrl: String,senderId: String){
       
        databaseReference.child(senderId).child(DataBaseReferencePaths.USER_MESSAGES).child(senderUserId).observeSingleEvent(of: .value) {
            (snapshot: DataSnapshot) in
            
            if !snapshot.exists(){
                let data: Dictionary<String, Any> = [DataBaseReferencePaths.EMAIL: senderUserEmail, DataBaseReferencePaths.FULL_NAME: senderUserName, DataBaseReferencePaths.IMAGE_URL: senderUserImageUrl]
                self.databaseReference.child(senderId).child(DataBaseReferencePaths.USER_MESSAGES).child(senderUserId).setValue(data)
            }
        }
    }
    
    func userIsSigningOut(senderId: String){
       databaseReference.child(senderId).child(DataBaseReferencePaths.USER_MESSAGES).removeValue()
    }
 
    func userSwippedToDeleteMessages(senderId: String, senderUserId: String){
        databaseReference.child(senderId).child(DataBaseReferencePaths.USER_MESSAGES).child(senderUserId).removeValue()
        
    }
    
    func getPublickey(senderUserId: String)->String{
        let publicKey = databaseReference.child(senderUserId).child(DataBaseReferencePaths.RSA).value(forKey: DataBaseReferencePaths.RSA)
        return publicKey as! String
    }
    
    func keySharingSend(encryptedKey: String,senderId: String, senderUserId: String){
        databaseReference.child(senderUserId).child(DataBaseReferencePaths.USER_MESSAGES).child(senderId).child(DataBaseReferencePaths.AESKEY).setValue(encryptedKey)
        
    }
    
    func keySharingReceive(senderId: String, senderuserId: String){
        databaseReference.child(senderId).child(DataBaseReferencePaths.USER_MESSAGES).child(senderuserId).child(DataBaseReferencePaths.AESKEY).observeSingleEvent(of: .value, with: {
            (snapshot: DataSnapshot) in
            
            if snapshot.exists(){
                let key = snapshot.value as! String
                do{
                    let decryptedKey = try SecurityFramework.security.rsaDecryption(message: key)
                    SecurityFramework.security.saveIntoKeyChain(data: decryptedKey,key: senderuserId)
                    
                }
                catch{
                    print("Error in decrypting rsa key:",error)
                }
            }
        })
    }
    
    
}
