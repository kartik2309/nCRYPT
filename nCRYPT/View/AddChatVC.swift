//
//  AddChatVC.swift
//  nCRYPT
//
//  Created by Kartik on 22/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import UIKit

class AddChatVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, FetchUser {

    //MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchCollectionview: UICollectionView!
    
    //MARK: Variables
    var searchResults = [SearchHandlerToAddChat]()
    var name = String()
    var email = String()
    var userId = String()
    var imageUrl = String()
    var chatVc = ChatVC()
    var senderId = String()
    
    //MARK: Identifiers
    let ADD_CHAT_CELL = "AddChatCell"
    
    //MARK: Segues
    let MESSAGES_SUGUE = "MessagesSegueFromAddChat"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        DatabaseProvider.Instance.searchResultsDelegate = self
        
        searchBar.delegate = self
        
        searchCollectionview.delegate = self
        searchCollectionview.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnCollectionView))
        tapGesture.cancelsTouchesInView = false
        
        searchCollectionview.addGestureRecognizer(tapGesture)
    
        senderId = AuthenticationProvider.Instance.userId()

    }
    
    func getUserDetails(searchResultDetails: [SearchHandlerToAddChat]) {
        searchResults = searchResultDetails
        searchCollectionview.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: Collection View Function
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let searchCell = collectionView.dequeueReusableCell(withReuseIdentifier: ADD_CHAT_CELL, for: indexPath) as! AddChatCollectionViewCell
        
        StorageProvider.Instance.downloadUserImage(cell: searchCell, url: searchResults[indexPath.row].imageUrl)
        
        searchCell.userImage.layer.cornerRadius = searchCell.userImage.frame.size.height/2
        searchCell.userImage.clipsToBounds = true
        
        searchCell.userNameLabel.text = searchResults[indexPath.row].name
        searchCell.userEmailLabel.text = searchResults[indexPath.row].email
        
        return searchCell
        
    }
    
    
    @objc func tappedOnCollectionView(_ sender: UITapGestureRecognizer){
        searchBar.resignFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        name = searchResults[indexPath.row].name
        email = searchResults[indexPath.row].email
        userId = searchResults[indexPath.row].userId
        imageUrl = searchResults[indexPath.row].imageUrl
        
        performSegue(withIdentifier: MESSAGES_SUGUE, sender: nil)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == MESSAGES_SUGUE{
            
            StorageProvider.Instance.downloadCurrentUserImage(url: imageUrl, imageName: userId + "userImage")
    
            let navigationController = segue.destination as? UINavigationController
            let chatVc = navigationController?.topViewController as? ChatVC
            
            chatVc?.name = name
            chatVc?.uid = userId
            chatVc?.email = email
            chatVc?.url = imageUrl
            
        }
    }
    
    //MARK: Search Bar Functions
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let newSearchText = searchText.lowercased()
        DatabaseProvider.Instance.searchForUsers(searchText: newSearchText)
       
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK: Actions
    
    @IBAction func cancelAction(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }

}
