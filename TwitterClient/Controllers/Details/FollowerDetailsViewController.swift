//
//  FollowerDetailsViewController.swift
//  TwitterClient
//
//  Created by MACC on 3/8/18.
//  Copyright © 2018 Rami. All rights reserved.
//

import UIKit
import Alamofire

class FollowerDetailsViewController: UIViewController {
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var personalImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var handle: UILabel!
    @IBOutlet weak var friendsNumber: UILabel!
    @IBOutlet weak var followersNumber: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var tweetsTableView: UITableView!
    
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    var selectedUserID: String?
    
    var tweetsList = [TweetsResponse]()
    var backgroundImageURL: String?
    var userImage: UIImage?
    var userImageUrl: String?
    var username: String?
    var userHandler: String?
    var numberOfFriends: Int?
    var numberOfFollowers: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        tweetsTableView.delegate = self
        tweetsTableView.dataSource = self
        
        //Always shows data from left to right
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        
        //Initailize core data context
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        
        //To get original image size
        let bgOriginalImageURL = backgroundImageURL?.replacingOccurrences(of: "_normal", with: "")
        let userOriginalImageURL = userImageUrl?.replacingOccurrences(of: "_normal", with: "")
        
        //localize current screen
        localizeCurrentViewController()
        
        //download background image
        downloadBackgroundImage(bgOriginalImageURL, completion: {(image) in
            DispatchQueue.main.async {
                self.backgroundImage.image = image
            }
        })
        
        //download user image if not loaded
        if let image = userImage {
            personalImage.image = image
        } else {
            downloadBackgroundImage(userOriginalImageURL, completion: {(image) in
                DispatchQueue.main.async {
                    self.personalImage.image = image
                }
            })
        }
        
        
        //fill user data
        name.text = username
        handle.text = userHandler != nil ? "@\(userHandler!)" : nil
        friendsNumber.text = String(numberOfFriends ?? 0)
        followersNumber.text = String(numberOfFollowers ?? 0)
        
        //fetch last 10 tweets
        fetchTweets()
    }
    
    
    
    /**
     Localizing the viewController.
     
     */
    private func localizeCurrentViewController() {
        viewTitle.text = NSLocalizedString("details", comment: "")
        friendsLabel.text = NSLocalizedString("friends", comment: "")
        followersLabel.text = NSLocalizedString("followers", comment: "")
        tweetsLabel.text = NSLocalizedString("tweets", comment: "")
    }
    
    /**
     Downloading the user background image in background.
     
     - parameters:
        - imageURL: The URL string for the image.
        - completion: The downloaded image.
     */
    private func downloadBackgroundImage(_ imageURL: String?, completion: @escaping (UIImage)->()) {
        if let url = imageURL {
            DispatchQueue.global(qos: .userInitiated).async {
                Alamofire.request(url).responseData { (response) in
                    if let imageData = response.result.value,
                        let image = UIImage(data: imageData) {
                        completion(image)
                    }
                }
            }
        }
    }
    
    /**
     Fetches the tweets list for the selected follower.
     
     */
    private func fetchTweets() {
        guard let userID = UserDefaults.standard.string(forKey: "currentUserID"),
            let userData = fetchUser(id: userID),
            let token = userData.value(forKey: "userToken") as? String,
            let tokenSecret = userData.value(forKey: "userTokenSecret") as? String,
            let selectedID = selectedUserID
            else{return}
        
        let client = OAuthClient(consumerKey: Constants.CONSUMER_KEY,
                                 consumerSecret: Constants.CONSUMER_SECRET,
                                 accessToken: token,
                                 accessTokenSecret: tokenSecret)
        
        let url = "\(Constants.API_BASE_URL)/\(Constants.API_VERSION)/\(Constants.TWEETS_ROUTE)"
        
        let params: [String: String] = [
            "user_id": selectedID,
            "count": String(10)
        ]
        
        BackendManager().fetchTweetsListFromAPI(client, url, params) { (tweets, err) in
            if let error = err {
                print(error.localizedDescription)
                self.showError(NSLocalizedString("notAuth", comment: ""))
            } else if let list = tweets {
                if list.count > 0 {
                    //there is tweets
                    self.tweetsList = list
                    
                    DispatchQueue.main.async {
                        self.tweetsTableView.reloadData()
                    }
                } else {
                    //no tweets
                    self.showError(NSLocalizedString("noTweets", comment: ""))
                }
            }
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
     Shows an error message on screen.
     
     - parameters:
        - msg: The message to be shown.
     */
    private func showError(_ msg: String) {
        DispatchQueue.main.async {
            self.tweetsTableView.isHidden = true
            self.errorLabel.text = msg
            self.errorLabel.isHidden = false
        }
    }
    
    /**
     Hides the error message if shown.
     
     */
    private func hideError() {
        DispatchQueue.main.async {
            self.tweetsTableView.isHidden = false
            self.errorLabel.isHidden = true
        }
    }
    
    /**
     Goes back to followers screen.
     
     */
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
