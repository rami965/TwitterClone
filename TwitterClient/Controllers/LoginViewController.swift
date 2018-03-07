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
        //Initailize core data
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext

        addLoginButton()
        
    }
    
    private func addLoginButton() {
        let logInButton = TWTRLogInButton(logInCompletion: { sessionObject, err in
            if let error = err {
                print("error: \(error.localizedDescription)")
            }else if let session = sessionObject {
                print("Username:", session.userName)
                print("UserID:", session.userID)
                print("Token:", session.authToken)
                print("Token secret:", session.authTokenSecret)
                
                //save current signed in user
                UserDefaults.standard.set(session.userID, forKey: "currentUser")
                
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
        
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
    
    private func fetchUser(id: String) -> NSManagedObject? {
        let predicate = NSPredicate(format: "userId == %@", id)
        let user = CoreDataHelper().fetchRecordsWithPredicate(predicate, "Users", inManagedObjectContext: managedContext).first
        
        return user
    }
    
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
    
    private func showFollowers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let followersViewController = storyboard.instantiateViewController(withIdentifier: "followersVC") as! FollowersViewController
        self.present(followersViewController, animated: true)
    }

}

