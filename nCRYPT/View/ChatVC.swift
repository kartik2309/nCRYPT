//
//  ChatVC.swift
//  nCRYPT
//
//  Created by Kartik on 09/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FetchMessagesSenderDetails, FetchMessageText, FetchLastMessageText, UISearchBarDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedViewController: UISegmentedControl!
    @IBOutlet weak var searchChat: UISearchBar!
    
    //MARK: Variables
    private var senderOfMessages = [MessageSenderHandler]()
    private var filteredData = [MessageSenderHandler]()
    private var newMessage = [UserMessageHandler]()
    private var newMessages = [UserMessageHandler]()
    private var messageHistoryInChat = String()
    private var senderUserName = String()
    private var senderUserId = String()
    private var senderEmail = String()
    private var senderImageUrl = String()
    private var lastMessageTextInString = String()
    private var messageVc = MessagesVC()
    private var senderId = String()
    private var flagForFiltering = Bool()
    lazy var infoViewController: InfoVc = {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewcontroller = storyBoard.instantiateViewController(withIdentifier: INFO_VIEW) as! InfoVc
        
        self.addViewControllerAsChildViewController(childViewController: viewcontroller)
        
        return viewcontroller
    }()
    
    var email = String()
    var name = String()
    var uid = String()
    var url = String()
    
    //MARK: Cell Identifier
    let CHAT_CELL = "ChatCell"
    let INFO_VIEW = "SignedInUserInfo"
    let ADD_NEW_CHAT = "AddChatVc"
    
    //MARK: Segues
    let SIGN_IN_SEGUE = "SignInSegue"
    let OPEN_MESSAGES = "OpenMessagesSegue"
    let MY_INFO_SEGUE = "MyInfoSegue"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //AuthenticationProvider.Instance.signOut()
        
        if !name.isEmpty && !email.isEmpty && !uid.isEmpty && !url.isEmpty{
            performSegue(withIdentifier: OPEN_MESSAGES, sender: self)
        }
        
        activityIndicator.startAnimating()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnCollectionView))
        tapGesture.cancelsTouchesInView = false
        
        
        
        chatCollectionView.addGestureRecognizer(tapGesture)
        chatCollectionView.delegate = self
        chatCollectionView.dataSource = self
        
        searchChat.delegate = self
        
        DatabaseProvider.Instance.messageDelegate = self
        DatabaseProvider.Instance.messageTextDelegate = self
        messageVc.lastMessageTextDelegate = self
        
        DatabaseProvider.Instance.getMessageSenderDetails()
        DatabaseProvider.Instance.getMessages()
        
        filteredData = senderOfMessages
        
        flagForFiltering = false
        
        senderId = UserDefaultHandler.Instance.currentUserId()
        
        let timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        timer.fire()

        setUpView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Delegate Functions
    func messageSenderData(senderOfMessages: [MessageSenderHandler]) {
        
        self.senderOfMessages = senderOfMessages
        
        if !flagForFiltering{
            filteredData = senderOfMessages
        }
        
    }
    
    func messagesText(message: [UserMessageHandler]){
        newMessage = message
        
        if newMessage.isEmpty{
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            
        }
        else{
            chatCollectionView.reloadData()
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            print(newMessage[0].messages)
        }
        
    }
    
    //MARK: Delegate functions
    
    func lastMessageText(lastMessageText: String) {
        lastMessageTextInString = lastMessageText
    }
    
    //MARK: Update Method for timer(Real Time Update)
    @objc func update(){
        
        DatabaseProvider.Instance.getMessageSenderDetails()
        DatabaseProvider.Instance.getMessages()
    }
    
    //MARK: Segment Control Function
    private func setUpView(){
        setUpSegmentedControl()
        updateView()
    }
    
    private func updateView(){
        infoViewController.view.isHidden = (segmentedViewController.selectedSegmentIndex == 0)
        if segmentedViewController.selectedSegmentIndex == 1 {
            searchChat.resignFirstResponder()
        }
    }
    
    private func setUpSegmentedControl(){
        segmentedViewController.removeAllSegments()
        segmentedViewController.insertSegment(withTitle: "Chats", at: 0, animated: true)
        segmentedViewController.insertSegment(withTitle: "Info", at: 1, animated: true)
        segmentedViewController.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        segmentedViewController.selectedSegmentIndex = 0
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl){
        updateView()
    }
    
    func addViewControllerAsChildViewController(childViewController: UIViewController){
        addChildViewController(childViewController)
        
        view.addSubview(childViewController.view)
        
        childViewController.view.frame = view.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        childViewController.didMove(toParentViewController: self)
    }
    
    //MARK: SearchBar Controller
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let newsearchText = searchText.lowercased()
        if searchText != ""{
            filteredData = senderOfMessages.filter({
                userName in
                return userName.name.contains(newsearchText)
            })
            flagForFiltering = true
            chatCollectionView.reloadData()
        }
        else{
            filteredData = senderOfMessages
            flagForFiltering = false
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchChat.resignFirstResponder()
    }
    
    
    //MARK: Collection View Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let chatCell = collectionView.dequeueReusableCell(withReuseIdentifier: CHAT_CELL, for: indexPath) as! ChatCollectionViewCell
        
        let cSelector = #selector(self.handleLeftSwipe(_:))
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: cSelector )
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        chatCell.addGestureRecognizer(leftSwipe)
        
        StorageProvider.Instance.downloadUserImage(cell: chatCell, url: filteredData[indexPath.row].imageUrl, userId: filteredData[indexPath.row].userId)
        

        chatCell.userImage.layer.cornerRadius = chatCell.userImage.frame.size.height/2
        chatCell.userImage.clipsToBounds = true
        
        chatCell.userNameLabel.text = filteredData[indexPath.row].name
        
        print("index path:", indexPath.row)
        
        print("size:",newMessage[0].messages.count)
        
        
        if newMessage[indexPath.row].messages.last != nil {
            
            let lastMessageData = SecurityFramework.security.base64StringToData(input: newMessage[indexPath.row].messages.last!)
            let currentUserId = UserDefaultHandler.Instance.currentUserId()
            
            print("retrieved key:",newMessage[indexPath.row].keys.last as Any)
            
            do {
                let decryptedKey = try SecurityFramework.security.rsaDecryption(message: newMessage[indexPath.row].keys.last!, userId: currentUserId)
                
                let decryptedKeyData = SecurityFramework.security.stringToData(input: decryptedKey)
                
                
                print("aes Key",decryptedKey)
                
                let decryptedMessage = SecurityFramework.security.dataToString(input: try SecurityFramework.security.aes256Decryption(data: lastMessageData!, keyData: decryptedKeyData!)!)  
                
                chatCell.chatPreviewLabel.text = decryptedMessage
                
            }
            catch {
                print("Error occured in the ChatVC", error)
            }
            
            
            chatCell.chatPreviewLabel.font = UIFont.boldSystemFont(ofSize: 16)
            chatCell.chatPreviewLabel.textColor = UIColor.black
        }
        else{
            
            messageVc.getLastMessage(senderId: UserDefaultHandler.Instance.currentUserId(), senderUserId: filteredData[indexPath.row].userId, senderName: filteredData[indexPath.row].name, receiverName: UserDefaultHandler.Instance.currentUserName())
            chatCell.chatPreviewLabel.text = lastMessageTextInString
            chatCell.chatPreviewLabel.font = UIFont.systemFont(ofSize: 16)
            chatCell.chatPreviewLabel.textColor = UIColor.gray
            
        }
        
        return chatCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        senderUserName = filteredData[indexPath.row].name
        senderUserId = filteredData[indexPath.row].userId
        senderEmail = filteredData[indexPath.row].email
        senderImageUrl = filteredData[indexPath.row].imageUrl
        
        newMessages.removeAll()
        newMessages.append(newMessage[indexPath.row])
        
        
        
        performSegue(withIdentifier: OPEN_MESSAGES, sender: self)
        
        
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        let cellSize: CGSize = CGSize(width: chatCollectionView.bounds.width, height: 94)
        return cellSize
    }
    
    @objc func tappedOnCollectionView(_ sender: UITapGestureRecognizer){
        searchChat.resignFirstResponder()
    }
    
    @objc func handleLeftSwipe(_ sender: UISwipeGestureRecognizer){
        let cell = sender.view as! ChatCollectionViewCell
        let i = self.chatCollectionView.indexPath(for: cell)!.item
        filteredData.remove(at: i)
        newMessage.remove(at: i)
        
        DatabaseProvider.Instance.userSwippedToDeleteMessages(senderId: UserDefaultHandler.Instance.currentUserId(), senderUserId: senderOfMessages[i].userId)
        
        FileManagerHandler.Instance.userSwippedToDeleteMessages(senderId: UserDefaultHandler.Instance.currentUserId(), senderUserId: senderOfMessages[i].userId)
        
        self.chatCollectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == OPEN_MESSAGES{
            
            searchChat.resignFirstResponder()
            
            if !name.isEmpty && !email.isEmpty && !uid.isEmpty && !url.isEmpty {
                let messageViewController = segue.destination as? MessagesVC
                
                messageViewController?.senderUserName = name
                messageViewController?.senderUserId = uid
                messageViewController?.senderEmail = email
                messageViewController?.senderImageUrl = url
                
                name.removeAll()
                uid.removeAll()
                email.removeAll()
                url.removeAll()
                
                
            }
            else{
                let messageViewController = segue.destination as? MessagesVC
                
                messageViewController?.senderUserName = senderUserName
                messageViewController?.senderUserId = senderUserId
                messageViewController?.messagesInString = newMessages
                messageViewController?.senderEmail = senderEmail
                messageViewController?.senderImageUrl = senderImageUrl
                
                
            }
        }
    }
    

    //MARK: Actions
    
    @IBAction func addChatAction(_ sender: Any){
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let addChatVc = storyBoard.instantiateViewController(withIdentifier: ADD_NEW_CHAT) as! AddChatVC
        present(addChatVc, animated: true, completion: nil)
    }
    
}
