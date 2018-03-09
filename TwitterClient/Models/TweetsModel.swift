//
//  TweetsModel.swift
//  TwitterClient
//
//  Created by MACC on 3/8/18.
//  Copyright © 2018 Rami. All rights reserved.
//

import Foundation
import ObjectMapper

class TweetsResponse: Mappable {
    var created_at: String?
    var text: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        created_at      <- map["created_at"]
        text            <- map["text"]
    }
}
