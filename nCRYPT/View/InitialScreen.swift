//
//  InitialScreen.swift
//  nCRYPT
//
//  Created by Kartik on 09/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import UIKit

class InitialScreen: UIViewController {
    
    let SIGN_IN_SEGUE = "SignInScreenSegue"
    let CHAT_SEGUE_FROM_FIRST_SCREEN = "ChatSegueFromFirstScreen"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AuthenticationProvider.Instance.isSignedIn(){
            performSegue(withIdentifier: CHAT_SEGUE_FROM_FIRST_SCREEN, sender: nil)
        }
        else{
            performSegue(withIdentifier: SIGN_IN_SEGUE, sender: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
