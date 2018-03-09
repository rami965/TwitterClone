//
//  TweetsTableViewDelegateDataSource.swift
//  TwitterClient
//
//  Created by MACC on 3/8/18.
//  Copyright © 2018 Rami. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Tweets TableView Delegate and DataSource
extension FollowerDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tweetsList.count
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetsCell") as! TweetsTableViewCell

        cell.tweetText.text = tweetsList[indexPath.section].text
        cell.personalImage.image = userImage
        
        return cell
    }
}
