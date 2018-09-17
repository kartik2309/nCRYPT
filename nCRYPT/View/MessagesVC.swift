//
//  MessagesVC.swift
//  nCRYPT
//
//  Created by Kartik on 09/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import UIKit
import JSQMessagesViewController

protocol FetchLastMessageText: class {
    func lastMessageText(lastMessageText: String)
}

class MessagesVC: JSQMessagesViewController, FetchMessageHistoryFromLocal, FetchMessageInRealTime{
    
    //MARK: Outlets
    
    @IBOutlet weak var messageNavigationBar: UINavigationItem!
    
    
    //MARK: Variables
    
    //(Details of the receiver)
    var senderUserName = String()
    var senderUserId = String()
    var senderEmail = String()
    var senderImageUrl = String()
    
    //(Details of the sender (Self) )
    var email = String()
    var imageUrl = String()
    
    var messagesInString = [String]()
    private var messages = [JSQMessage]()
    private var userName = String()
    private var messageHistoryInChat = String()
    private var keyForEncryption = String()
    private var keyForDecrpytion = String()
    private var ivForEncryption = String()
    private var ivForDecrpytion = String()
    private var flag = Bool()
    
    //(Security Parameters)
    private var sessionKey = String()
    

    //Mark: Segues
    let INFO_SEGUE = "InfoSegue"
    
    //MARK: Delegates
    weak var lastMessageTextDelegate: FetchLastMessageText?
    
    override func viewWillAppear(_ animated: Bool) {
        messageNavigationBar.title = senderUserName
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Setting up Security Parameters.
        
        do{
            sessionKey = SecurityFramework.security.aesKeyGeneration()
            let publicKey = DatabaseProvider.Instance.getPublickey(senderUserId: senderUserId)
            let encryptedKey = try SecurityFramework.security.rsaEncryption(message: sessionKey, publicKeyPEM: publicKey)
            
            
        }catch{
            print("Error occured in messageVc",error)
        }
        
        
        
        //Setting up the chat background color
        collectionView.backgroundColor = UIColor.clear
    
        //Setting up sender's details(Self)
        senderId = AuthenticationProvider.Instance.userId()
        senderDisplayName = UserDefaultHandler.Instance.currentUserName()
        email = UserDefaultHandler.Instance.currentUserEmail()
        imageUrl = UserDefaultHandler.Instance.currentUserImageUrl()
        
        //Flag set to false when the view controller is not in the current view.
        flag = true
        
        //No media sending enabled
        inputToolbar.contentView.leftBarButtonItem = nil
        
        
        //Loading Chat History
        FileManagerHandler.Instance.messageHistoryDelegate = self
        FileManagerHandler.Instance.loadChatLog(senderId: senderId, senderUserId: senderUserId)
        
        
        
        
        //Load previous messages as well as newly received messages
        loadMessages()
        
        //Update the view with realtime messages.
        DatabaseProvider.Instance.messageInRealTimeDelegate = self
        let timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        timer.fire()
        
        if !flag{
            timer.invalidate()
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: JSQ Functions
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
    
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.blue)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.gray)
            
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId{
            return JSQMessagesAvatarImageFactory.avatarImage(with: FileManagerHandler.Instance.getSavedImage(named: senderId + "userImage")!, diameter: 30)
        }
        else{
            return JSQMessagesAvatarImageFactory.avatarImage(with: FileManagerHandler.Instance.getSavedImage(named: senderUserId), diameter: 30)
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {

        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        

        return cell
    }
    

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        
        let messageData = SecurityFramework.security.stringToData(input: text)
        
        let keyData = SecurityFramework.security.stringToData(input: SecurityFramework.security.aesKeyGeneration())
        
        
        do {
            let encryptedData = try SecurityFramework.security.aes256Encryption(data: messageData!, keyData: keyData!)
            let encryptedString = encryptedData.base64EncodedString()
            
            
            let decryptedData = try SecurityFramework.security.aes256Decryption(data: encryptedData, keyData: keyData!)
            let decryptedString = SecurityFramework.security.datatoString(input: decryptedData!)
            
            print("Encrypted Text:", encryptedString)
            print("Decrypted Text:", decryptedString!)
            
        } catch {
            print("Error Occured in message VC", error)
        }
        
        
       /* DatabaseProvider.Instance.sendMessageToDatabase(senderUserId: senderUserId,senderName: senderDisplayName, senderEmail: email, senderImageUrl: imageUrl, senderId: senderId, message: encryptedText)
        
        DatabaseProvider.Instance.saveNewChat(senderUserId: senderUserId, senderUserName: senderUserName, senderUserEmail: senderEmail, senderUserImageUrl: senderImageUrl, senderId: senderId)
        
        FileManagerHandler.Instance.saveChatLog(senderId: senderId, senderUserId: senderUserId, message: text, senderAtTheMoment: senderId)
        */
        
        collectionView.reloadData()
        
        finishSendingMessage()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil{
            flag = false
            
        }
    }
    
    //MARK: Local Functions
    
    func loadMessages(){
        
        DatabaseProvider.Instance.removeMessages(senderId: senderId, senderUserId: senderUserId)
        
        let messageArray = messageHistoryInChat.split(separator: "`")
        
        for i in 0 ..< messageArray.count{
            
            let newArray = messageArray[i].split(separator: "-")
            
            let uid = String(newArray[0])
            let messageText = String(newArray[1])
            let displayName = getNameWithUid(uid: uid)
    
            messages.append(JSQMessage(senderId: uid, displayName: displayName, text: messageText))
        }
        
        for i in (0 ..< messagesInString.count){
            
            let decryptedString = ""
            //let decryptedString = SecurityFramework.security.aes256Decryption(messageText: messagesInString[i], keyData: keyForDecrpytion, iv: ivForDecrpytion)
            
            messages.append(JSQMessage(senderId: senderUserId, displayName: senderUserName, text: decryptedString))
            
            
            FileManagerHandler.Instance.saveChatLog(senderId: senderId, senderUserId: senderUserId, message: decryptedString, senderAtTheMoment: senderUserId)
            
        }

        messageHistoryInChat.removeAll()
        messagesInString.removeAll()
        collectionView.reloadData()
    }
    
    
    func recieveMessageContent(messageHistory: String){
        messageHistoryInChat = messageHistory
    }
    
    func getNameWithUid(uid: String) -> String{
        
        if uid == senderUserId{
            //name of the person who sent the message
            return senderUserName
        }
        else{
            //self name
            return senderDisplayName
        }
        
    }
    
    func getLastMessage(senderId: String, senderUserId: String, senderName: String, receiverName: String){
        FileManagerHandler.Instance.messageHistoryDelegate = self
        FileManagerHandler.Instance.loadChatLog(senderId: senderId, senderUserId: senderUserId)
        
        
        if messageHistoryInChat.isEmpty {
            lastMessageTextDelegate?.lastMessageText(lastMessageText: "")
        }
        else{
            
            let messageArray = messageHistoryInChat.split(separator: "`")
            var userNameWithUidDictionary: Dictionary<String, String> = [senderUserId: senderName, senderId: receiverName]
            
            for i in 0 ..< messageArray.count{
                
                let newArray = messageArray[i].split(separator: "-")
                
                let uid = String(newArray[0])
                let messageText = String(newArray[1])
                let displayName = String(userNameWithUidDictionary[uid]!)
                
                
                messages.append(JSQMessage(senderId: uid, displayName: displayName, text: messageText))
                
                lastMessageTextDelegate?.lastMessageText(lastMessageText: (messages.last?.text!)!)
                
            }
            userNameWithUidDictionary.removeAll()
        }
    }
    
    func recieveMessagesInRealTime(messages : [String]){
        messagesInString = messages
    }
    
    func updateInRealTime(){
        
        
        if !messagesInString.isEmpty{
            
            for i in (0 ..< messagesInString.count){
                let decryptedString = ""
                //let decryptedString = SecurityFramework.security.aes256Decryption(messageText: messagesInString[i], keyData: keyForDecrpytion, iv: ivForDecrpytion)
                
                messages.append(JSQMessage(senderId: senderUserId, displayName: senderDisplayName, text: decryptedString))
                
                FileManagerHandler.Instance.saveChatLog(senderId: senderId, senderUserId: senderUserId, message: decryptedString, senderAtTheMoment: senderUserId)
            }
            messagesInString.removeAll()
        }
        collectionView.reloadData()
        
    }
    
    //MARK: Update the chat in real time
    @objc func update(){
        DatabaseProvider.Instance.deliverMessagesDirectlyToMessageView(senderId: senderId, senderUserId: senderUserId, flag: flag)
        updateInRealTime()

    }
    
    //MARK: Perpare Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == INFO_SEGUE{
            
            let userInfo = segue.destination as? UserInfoVC
            
            userInfo?.userId = senderUserId
            userInfo?.userName = senderUserName
            userInfo?.userEmail = senderEmail
        }
    }
    
    //MARK: Actions
    
    @IBAction func infoAction(_ sender: Any) {
        performSegue(withIdentifier: INFO_SEGUE, sender: nil)
    }
}
