//
//  InfoVc.swift
//  nCRYPT
//
//  Created by Kartik on 27/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import UIKit

class InfoVc: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    //MARK: Variables
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.image = FileManagerHandler.Instance.getSavedImage(named: AuthenticationProvider.Instance.userId() + "userImage")
        
        userNameLabel.text = UserDefaultHandler.Instance.currentUserName()
        userEmailLabel.text = UserDefaultHandler.Instance.currentUserEmail()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.height/2
        userImageView.clipsToBounds = true
        
        submitButton.layer.cornerRadius = 30
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOutAction(_ sender: Any){
        
        DatabaseProvider.Instance.userIsSigningOut(senderId: AuthenticationProvider.Instance.userId())
        FileManagerHandler.Instance.userIsSigningOut()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let signInVc = storyBoard.instantiateViewController(withIdentifier: "SignInVc") as! SignInVC
        present(signInVc, animated: true, completion: nil)
    }
}
