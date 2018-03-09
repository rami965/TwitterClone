//
//  LoginViewController.swift
//  TwitterClient
//
//  Created by MACC on 3/5/18.
//  Copyright © 2018 Rami. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Initailize core data context
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext

        addLoginButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = UserDefaults.standard.string(forKey: "currentUserID") {
            //there was logged user
            showFollowers()
        }
    }
    
    /**
     Adding login button and handling its action.
     */
    private func addLoginButton() {
        let logInButton = TWTRLogInButton(logInCompletion: { sessionObject, err in
            if let error = err {
                print("error: \(error.localizedDescription)")
                Utils.showAlert(title: "Error", message: error.localizedDescription, vc: self)
            }else if let session = sessionObject {
                print("Username:", session.userName)
                print("UserID:", session.userID)
                print("Token:", session.authToken)
                print("Token secret:", session.authTokenSecret)
                
                //save current signed in user
                UserDefaults.standard.set(session.userID, forKey: "currentUserID")
                
                //check and update user
                if let existingUser = self.fetchUser(id: session.userID) {
                    //update user
                    print("User already saved.")
                    self.updateUserCredintials(existingUser,
                                               session.authToken,
                                               session.authTokenSecret)
                } else {
                    //add new user
                    print("Saving new user.")
                    self.saveNewUserCredentials(session.authToken,
                                                session.userID,
                                                session.userName,
                                                session.authTokenSecret)
                }
                
                self.showFollowers()
            }
        })
        
        logInButton.layer.cornerRadius = 10.0
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
    
    /**
     Fetches a single user with user ID.
     
     - parameters:
        - id: The user ID to be fetched.
     */
    private func fetchUser(id: String) -> NSManagedObject? {
        let predicate = NSPredicate(format: "userId == %@", id)
        let user = CoreDataHelper().fetchRecordsWithPredicate(predicate, "Users", inManagedObjectContext: managedContext).first
        
        return user
    }
    
    /**
     Updates credentials for a single user.
     
     - parameters:
         - user: The user managed object.
         - token: The user auth token.
         - tokenSecret: The user auth token secret.
     */
    private func updateUserCredintials(_ user: NSManagedObject, _ token: String, _ tokenSecret: String) {
        user.setValue(token, forKey: "userToken")
        user.setValue(tokenSecret, forKey: "userTokenSecret")
        
        do {
            // Update Managed Object Context
            try managedContext.save()
            print("User updated successfully")
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /**
     Add a new user data with credentials.
     
     - parameters:
         - token: The user auth token.
         - userID: The ID of the new user.
         - username: The user name to be saved.
         - tokenSecret: The new user auth token secret.
     */
    private func saveNewUserCredentials(_ token: String, _ userID: String, _ username: String, _ tokenSecret: String) {
        if let user = CoreDataHelper().createRecordForEntity("Users", inManagedObjectContext: managedContext) {
            user.setValue(userID, forKey: "userId")
            user.setValue(username, forKey: "username")
            user.setValue(token, forKey: "userToken")
            user.setValue(tokenSecret, forKey: "userTokenSecret")
            
            do {
                // Save Managed Object Context
                try managedContext.save()
                print("User created successfully")
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Can't create user object.")
        }
    }
    
    /**
     Shows the followers for the current logged in user.
     
     */
    private func showFollowers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let followersViewController = storyboard.instantiateViewController(withIdentifier: "followersVC") as! FollowersViewController
        self.present(followersViewController, animated: true)
    }

}

