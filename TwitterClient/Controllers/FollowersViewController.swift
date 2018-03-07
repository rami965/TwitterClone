//
//  FollowersViewController.swift
//  TwitterClient
//
//  Created by MACC on 3/6/18.
//  Copyright © 2018 Rami. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class FollowersViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var followersTableView: UITableView!
    
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    var followersList = [Follower]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        followersTableView.delegate = self
        followersTableView.dataSource = self
        
        //Initailize core data context
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //hide error label
        hideError()
        
        //check saved followers
        let list = fetchSavedFollowers()
        if list.count > 0 {
            //there is saved list
            followersList = list
            followersTableView.reloadData()
            fetchOnlineFollowersList()
            
        } else {
            //no saved list
            fetchOnlineFollowersList()
        }
    }
    
    private func fetchOnlineFollowersList() {
        guard let userID = UserDefaults.standard.string(forKey: "currentUser"),
            let userData = fetchUser(id: userID),
            let token = userData.value(forKey: "userToken") as? String,
            let tokenSecret = userData.value(forKey: "userTokenSecret") as? String
            else{return}
        
        let client = OAuthClient(consumerKey: Constants.CONSUMER_KEY,
                                 consumerSecret: Constants.CONSUMER_SECRET,
                                 accessToken: token,
                                 accessTokenSecret: tokenSecret)
        
        let url = "\(Constants.API_BASE_URL)/\(Constants.API_VERSION)/\(Constants.FOLLOWERS_ROUTE)"
        
        let params: [String: String] = [
            "user_id": userID,
            "include_user_entities": String(false),
            "skip_status": String(true),
            "cursor": String(-1)
        ]
        
        BackendManager().fetchFollowersListFromAPI(client, url, params) { (followers, err) in
            if let error = err {
                print(error.localizedDescription)
            } else if let list = followers?.users {
                if list.count > 0 {
                    //have followers
                    self.followersList.removeAll()
                    self.followersList = list
                    
                    DispatchQueue.main.async {
                        self.followersTableView.reloadData()
                    }
                    
                    //TODO update core data
                    self.saveFollowers(list)
                    
                } else {
                    //no followers
                    self.showError("You have no followers.")
                }
            }
        }
    }
    
    private func fetchUser(id: String) -> NSManagedObject? {
        let predicate = NSPredicate(format: "userId == %@", id)
        let user = CoreDataHelper().fetchRecordsWithPredicate(predicate, "Users", inManagedObjectContext: managedContext).first
        
        return user
    }
    
    private func fetchSavedFollowers() -> [Follower] {
        var result = [Follower]()
        let list = CoreDataHelper().fetchRecordsForEntity("Followers", inManagedObjectContext: managedContext)
        for follower in list {
            let tmp = Follower(follower.value(forKey: "name") as? String,
                               follower.value(forKey: "handleId") as? String,
                               follower.value(forKey: "bio") as? String,
                               follower.value(forKey: "imageUrl") as? String)
            result.append(tmp)
        }
        
        return result
    }
    
    private func saveFollowers(_ list: [Follower]) {
        DispatchQueue.global(qos: .background).async {
            //clear old records
            CoreDataHelper().clearRecords("Followers", inManagedObjectContext: self.managedContext)
            
            //add new records
            for follower in list {
                if let tmp = CoreDataHelper().createRecordForEntity("Followers", inManagedObjectContext: self.managedContext) {
                    tmp.setValue(follower.name, forKey: "name")
                    tmp.setValue(follower.screen_name, forKey: "handleId")
                    tmp.setValue(follower.description, forKey: "bio")
                    tmp.setValue(follower.profile_image_url, forKey: "imageUrl")
                }
            }
            
            do {
                // Save Managed Object Context
                try self.managedContext.save()
                print("Followers saved successfully")
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func showError(_ msg: String) {
        DispatchQueue.main.async {
            self.followersTableView.isHidden = true
            self.errorLabel.text = msg
            self.errorLabel.isHidden = false
        }
    }

    private func hideError() {
        DispatchQueue.main.async {
            self.followersTableView.isHidden = false
            self.errorLabel.isHidden = true
        }
    }
}


