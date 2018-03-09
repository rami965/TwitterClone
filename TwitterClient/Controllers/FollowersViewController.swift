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
import DGElasticPullToRefresh

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
        
        
        // Initialize tableView with refresh indicator
        initializeRefreshIndicator()
        
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
            if let userID = UserDefaults.standard.string(forKey: "currentUser"){
                fetchOnlineFollowersList(userID)
            }
            
        } else {
            //no saved list
            Indicator().showActivityIndicator(uiView: self.view)
            if let userID = UserDefaults.standard.string(forKey: "currentUser"){
                fetchOnlineFollowersList(userID)
            }
        }
    }
    
    /**
     Initializing the refresh indicator.
     
     */
    private func initializeRefreshIndicator() {
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.white
        followersTableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            guard let userID = UserDefaults.standard.string(forKey: "currentUser") else {
                self?.followersTableView.dg_stopLoading()
                return
            }
            
            self?.fetchOnlineFollowersList(userID)
            }, loadingView: loadingView)
        followersTableView.dg_setPullToRefreshFillColor(UIColor.darkGray)
        followersTableView.dg_setPullToRefreshBackgroundColor(followersTableView.backgroundColor!)
    }
    
    /**
     Fetches followers list for specefic user.
     
     - parameters:
        - userID: The user ID used to get his followers.
     */
    private func fetchOnlineFollowersList(_ userID: String) {
        guard let userData = fetchUser(id: userID),
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
                    
                    //Update core data list
                    self.saveFollowers(list)
                    
                } else {
                    //no followers
                    self.showError("You have no followers.")
                }
            }
            
            //hide indicator
            Indicator().hideActivityIndicator(uiView: self.view)
            self.followersTableView.dg_stopLoading()
        }
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
     Fetches the saved followers list.
     
     */
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
    
    /**
     Saves the followers list to be used offline.
     
     - parameters:
        - list: The list of followers to be saved.
     */
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
    
    /**
     Shows an error message on screen.
     
     - parameters:
        - msg: The message to be shown.
     */
    private func showError(_ msg: String) {
        DispatchQueue.main.async {
            self.followersTableView.isHidden = true
            self.errorLabel.text = msg
            self.errorLabel.isHidden = false
        }
    }

    /**
     Hides the error message if shown.
     
     */
    private func hideError() {
        DispatchQueue.main.async {
            self.followersTableView.isHidden = false
            self.errorLabel.isHidden = true
        }
    }
    
    //removing the refresh indicator.
    deinit {
        followersTableView.dg_removePullToRefresh()
    }
}


