//
//  UserInfoVc.swift
//  nCRYPT
//
//  Created by Kartik on 15/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import UIKit

class UserInfoVC: UIViewController{

    //MARK: Outlets
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    //Mark: Variables
    var userId = String()
    var userName = String()
    var userEmail = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userImageView.image = FileManagerHandler.Instance.getSavedImage(named: userId)
        
        userNameLabel.text = userName
        userEmailLabel.text = userEmail
        
        userImageView.layer.cornerRadius = userImageView.frame.size.height/2
        userImageView.clipsToBounds = true
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
