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
import DropDown

class FollowersViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var followersTableView: UITableView!
    @IBOutlet weak var usersButton: UIButton!
    @IBOutlet weak var viewTitle: UILabel!
    
    //users drop down
    let usersDropDown = DropDown()

    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    var followersList = [Follower]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        followersTableView.delegate = self
        followersTableView.dataSource = self
        
        //Always shows data from left to right
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        
        //Initailize core data context
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        
        //set title
        viewTitle.text = NSLocalizedString("followers", comment: "")
        
        //Initialize tableView with refresh indicator
        initializeRefreshIndicator()
        
        //Initialize users drop down
        initializeUsersDropDown()
        
        //check saved followers
        checkSavedFollowers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //hide error label
        hideError()
    }
    
    /**
     Initializing the refresh indicator.
     
     */
    private func initializeRefreshIndicator() {
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.white
        followersTableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            guard let userID = UserDefaults.standard.string(forKey: "currentUserID") else {
                self?.followersTableView.dg_stopLoading()
                return
            }
            
            self?.fetchOnlineFollowersList(userID)
            }, loadingView: loadingView)
        followersTableView.dg_setPullToRefreshFillColor(UIColor.darkGray)
        followersTableView.dg_setPullToRefreshBackgroundColor(followersTableView.backgroundColor!)
    }
    
    /**
     Initializing the uesrs drop down.
     
     */
    private func initializeUsersDropDown() {
        usersDropDown.anchorView = usersButton
        usersDropDown.bottomOffset = CGPoint(x: 0, y:(usersDropDown.anchorView?.plainView.bounds.height)!)
        let users = CoreDataHelper().fetchRecordsForEntity("Users", inManagedObjectContext: managedContext)
        var usernames = [String]()
        var userIDs = [String]()
        if users.count > 0 {
            //There is more than 1 user saved.
            for user in users {
                let tmpName = user.value(forKey: "username") as! String
                let tmpID = user.value(forKey: "userId") as! String
                
                usernames.append(tmpName)
                userIDs.append(tmpID)
            }
            //add logout option
            usernames.append("Logout")
            usersDropDown.dataSource = usernames
            
            handleUsersDropDownSelection(usernames, userIDs)
        }
    }
    
    /**
     Handling the users drop down selection.
     
     */
    private func handleUsersDropDownSelection(_ usernames: [String], _ userIDs: [String]) {
        usersDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            if item == usernames.last {
                //Logout
                UserDefaults.standard.removeObject(forKey: "currentUserID")
                self.dismiss(animated: true)
                
            } else if let currentUserID = UserDefaults.standard.string(forKey: "currentUserID"),
                currentUserID == userIDs[index] {
                //Current user selected
                print("Current user selected")
                
            } else {
                //other user selected
                UserDefaults.standard.set(userIDs[index], forKey: "currentUserID")
                Indicator().showActivityIndicator(uiView: self.view)
                self.followersList.removeAll()
                self.fetchOnlineFollowersList(userIDs[index])
            }
        }
    }
    
    /**
     Checks for saved followers list and fetch them from api if not saved.

     */
    private func checkSavedFollowers() {
        let list = fetchSavedFollowers()
        if list.count > 0 {
            //there is saved list
            followersList = list
            followersTableView.reloadData()
            if let userID = UserDefaults.standard.string(forKey: "currentUserID"){
                fetchOnlineFollowersList(userID)
            }
            
        } else {
            //no saved list
            Indicator().showActivityIndicator(uiView: self.view)
            if let userID = UserDefaults.standard.string(forKey: "currentUserID"){
                fetchOnlineFollowersList(userID)
            }
        }
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
                self.showError(error.localizedDescription)
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
    
    @IBAction func dropDownAction(_ sender: Any) {
        usersDropDown.show()
        print("FollowersViewController will be deinitialized")
    }
    
}


