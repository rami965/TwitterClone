//
//  FollowersTableViewCell.swift
//  TwitterClient
//
//  Created by MACC on 3/7/18.
//  Copyright © 2018 Rami. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

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
