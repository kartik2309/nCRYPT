//
//  InitialScreen.swift
//  nCRYPT
//
//  Created by Kartik on 09/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import UIKit
import LocalAuthentication

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
            
            let context = LAContext()
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Kindly Authenticate with TouchID", reply: {
                    (wasCorrect, error) in
                    
                    if wasCorrect {
                        self.performSegue(withIdentifier: self.CHAT_SEGUE_FROM_FIRST_SCREEN, sender: nil)
                    }
                    else{
                        self.alertTheUser(title: "Error", message: "We require your TouchID to authorize your login")
                    }
                })
            }
            else{
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enter You Passcode!", reply: {
                    (wasCorrect, error) in
                    
                    if wasCorrect {
                        self.performSegue(withIdentifier: self.CHAT_SEGUE_FROM_FIRST_SCREEN, sender: nil)
                    }
                    else{
                        self.alertTheUser(title: "Error", message: "We require your passcode to authorize your login")
                    }
                })
            }
            
        }
        else{
            performSegue(withIdentifier: SIGN_IN_SEGUE, sender: nil)
        }
    }
    
    
    //MARK: Private Functions
    private func alertTheUser(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }

}
