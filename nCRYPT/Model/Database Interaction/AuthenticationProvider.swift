
//
//  AuthenticationProvider.swift
//  nCRYPT
//
//  Created by Kartik on 08/06/18.
//  Copyright © 2018 Devsolutions. All rights reserved.
//

import Foundation
import Firebase

typealias SignInHandler = (_ msg: String?)-> Void
typealias SignUpHandler = (_ msg: String?)-> Void

protocol getEmailVerificationMessage: class{
    func getMessage(error: Error?)
}


//MARK: Structures

//Defining the structure to define the messages for error code
private struct SignInHandlerErrorCodes{
    
    static let INVALID_EMAIL = "Invalid Email Address. Kindly provide a valid Email Address!"
    static let WRONG_PASSWORD = "Kindly Provide the correct Password for your account."
    static let USER_NOT_FOUND = "User not found. To use Connect, kindly Sign Up."
    static let PROBLEM_CONNECTING = "An error occurred while performing the request. Please Check your Internet Connection"
    static let EMAIL_NOT_VERIFIED = "Kindly Verify your email to use WiRED"
}

private struct signUpHandlerErrorCodes{
    static let EMAIL_ALREADY_IN_USE = "Given Email is already in use. Kindly use another Email and try again"
    static let WEAK_PASSWORD = "Please choose a password of at least 6 characters long"
    static let PROBLEM_CONNECTING = "An error occurred while performing the request. Please Check your Internet Connection"
}

//MARK: Class

//Defining the class
class AuthenticationProvider{
    
    static private var _instance = AuthenticationProvider()
    
    static var Instance: AuthenticationProvider{
        return _instance
    }
    
    //MARK: Delegates
    weak var getMessageCodeDelegate: getEmailVerificationMessage?
    
    //MARK: Operations
    
    //Sign In Function
    func signIn(email: String, password: String, signInHandler: SignInHandler?){
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            
            if error != nil{
                self.signInErrorHandler(error: error! as NSError, signInHandler: signInHandler!)
            }
            else{

                if self.isEmailVerfied(){
                    signInHandler?(nil)
                }
                else{
                    let error = NSError(domain: "Please Verify your email", code: 0, userInfo: nil)
                    self.signInErrorHandler(error: error, signInHandler: signInHandler!)
                }
            }
        })
        
    }
    
    //Sign Up Function
    func signUp(email: String,fullName: String, password: String, userImage: UIImage, signUpHandler: SignUpHandler?){
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            
            (user, error) in
            
            if error != nil{
                self.signUpErrorHandler(error: error! as NSError, signUpHandler: signUpHandler!)
            }
            else{
                signUpHandler?(nil)
                
                if user != nil{
                    let userId = Auth.auth().currentUser?.uid
                    let pbkd = SecurityFramework.security.pdkf2sha512(password: password)
                    DatabaseProvider.Instance.saveNewRsaKey(userId: userId!, pbkd: pbkd!)
                    
                    StorageProvider.Instance.saveTheUser(userId: userId!, email: email, fullName: fullName, userImage: userImage, storageHandler: {
                        
                        (error) in
                        
                        if error != nil{
                            print(error as Any)
                        }
                        else{
                            
                            print("successfully saved details")
                        }
                    })
                }
            }
        })
        
        
    }
    
    func isSignedIn()-> Bool{
        if Auth.auth().currentUser?.uid != nil{
            return true
        }
        return false
    }
    
    func signOut() -> Bool{
        
        if Auth.auth().currentUser?.uid != nil{
            do{
                try Auth.auth().signOut()
                return true
            }
            catch{
                return false
            }
        }
        return true
    }
    
    func userId()-> String{
        return (Auth.auth().currentUser?.uid)!
    }
    
    func isEmailVerfied()->Bool{
        let currentUser = Auth.auth().currentUser
        return currentUser?.isEmailVerified ?? false
    }
    
    func sendEmailVerification(){
        Auth.auth().currentUser?.sendEmailVerification(completion: {
            (error) in
            
            if error != nil {
                //Error occured in sending an email
                self.getMessageCodeDelegate?.getMessage(error: error)
            }
            else{
                //Verfication email has been sent
                self.getMessageCodeDelegate?.getMessage(error: nil)
            }
            
        })
    }
    
    //MARK: Private Functions
    
    private func signInErrorHandler(error: NSError, signInHandler: SignInHandler){
        
        if let errorCode = AuthErrorCode(rawValue: error.code){
            
            switch errorCode{
                
            case .invalidEmail:
                signInHandler(SignInHandlerErrorCodes.INVALID_EMAIL)
                break
                
            case .wrongPassword:
                signInHandler(SignInHandlerErrorCodes.WRONG_PASSWORD)
                break
                
            case .userNotFound:
                signInHandler(SignInHandlerErrorCodes.USER_NOT_FOUND)
                break
                
            case .appNotVerified:
                signInHandler(SignInHandlerErrorCodes.EMAIL_NOT_VERIFIED)
                
            default:
                signInHandler(SignInHandlerErrorCodes.PROBLEM_CONNECTING)
                break
            }
        }
    }
    
    private func signUpErrorHandler(error: NSError, signUpHandler: SignUpHandler){
        
        if let errorCode = AuthErrorCode(rawValue: error.code){
            
            switch errorCode{
                
            case .emailAlreadyInUse:
                signUpHandler(signUpHandlerErrorCodes.EMAIL_ALREADY_IN_USE)
                break
            case .weakPassword:
                signUpHandler(signUpHandlerErrorCodes.WEAK_PASSWORD)
                
            default:
                signUpHandler(signUpHandlerErrorCodes.PROBLEM_CONNECTING)
                
            }
            
        }
        
    }
}
