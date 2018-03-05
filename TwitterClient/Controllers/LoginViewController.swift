//
//  LoginViewController.swift
//  TwitterClient
//
//  Created by MACC on 3/5/18.
//  Copyright © 2018 Rami. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        addLoginButton()
    }
    
    private func addLoginButton() {
        let logInButton = TWTRLogInButton(logInCompletion: { sessionObject, err in
            if let error = err {
                print("error: \(error.localizedDescription)")
            }else if let session = sessionObject {
                print("signed in as \(session.userName)")
                print("Token:", session.authToken)
                
                self.showFollowers()
            }
        })
        
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
    
    private func showFollowers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let followersViewController = storyboard.instantiateViewController(withIdentifier: "followersVC") as! FollowersViewController
        self.present(followersViewController, animated: true)
    }

}

