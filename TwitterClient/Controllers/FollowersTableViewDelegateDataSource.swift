//
//  FollowersTableViewDelegateDataSource.swift
//  TwitterClient
//
//  Created by MACC on 3/7/18.
//  Copyright © 2018 Rami. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Followers TableView Delegate and DataSource
extension FollowersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return followersList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame:CGRect (x: 0, y: 0, width: 320, height: 20) ) as UIView
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "followersCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! FollowersTableCell
        
        cell.downloadImage(followersList[indexPath.section].profile_image_url)
        cell.fullNameLabel.text = followersList[indexPath.section].name
        cell.handleLabel.text = "@\(followersList[indexPath.section].screen_name ?? "")"
        cell.bioLabel.text = followersList[indexPath.section].description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
