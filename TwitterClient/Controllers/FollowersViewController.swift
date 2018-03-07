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

class FollowersTableCell: UITableViewCell {
    @IBOutlet weak var personalImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    func downloadImage(_ imageURL: String?) {
        if let url = imageURL {
            DispatchQueue.global(qos: .userInitiated).async {
                Alamofire.request(url).responseData { (response) in
                    if let imageData = response.result.value,
                        let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.personalImageView.image = image
                        }
                    }
                }
            }
        }
    }
}

class FollowersViewController: UIViewController {

    @IBOutlet weak var followersTableView: UITableView!
    
    var followersList = [Follower]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        followersTableView.delegate = self
        followersTableView.dataSource = self
    }

}

extension FollowersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return followersList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "followersCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! FollowersTableCell
        
        cell.downloadImage(followersList[indexPath.section].profile_image_url)
        
        return cell
    }
}
