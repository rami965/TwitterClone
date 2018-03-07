//
//  FollowersModel.swift
//  TwitterClient
//
//  Created by MACC on 3/7/18.
//  Copyright © 2018 Rami. All rights reserved.
//

import Foundation
import ObjectMapper

class FollowersResponse: Mappable {
    var users: [Follower]?
    var next_cursor: Int?
    var next_cursor_str: String?
    var previous_cursor: Int?
    var previous_cursor_str: String?
    var errors: [APIError]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        users                   <- map["users"]
        next_cursor             <- map["next_cursor"]
        next_cursor_str         <- map["next_cursor_str"]
        previous_cursor         <- map["previous_cursor"]
        previous_cursor_str     <- map["previous_cursor_str"]
    }
}

class Follower: Mappable {
    var id: Int?
    var id_str: String?
    var name: String?
    var screen_name: String?
    var location: String?
    var url: String?
    var description: String?
    var protected: Bool?
    var followers_count: Int?
    var friends_count: Int?
    var listed_count: Int?
    var created_at: String?
    var favourites_count: Int?
    var utc_offset: Int?
    var time_zone: String?
    var geo_enabled: Bool?
    var verified: Bool?
    var statuses_count: Int?
    var lang: String?
    var contributors_enabled: Bool?
    var is_translator: Bool?
    var is_translation_enabled: Bool?
    var profile_background_color: String?
    var profile_background_image_url: String?
    var profile_background_image_url_https: String?
    var profile_background_tile: Bool?
    var profile_image_url: String?
    var profile_image_url_https: String?
    var profile_link_color: String?
    var profile_sidebar_border_color: String?
    var profile_sidebar_fill_color: String?
    var profile_text_color: String?
    var profile_use_background_image: Bool?
    var has_extended_profile: Bool?
    var default_profile: Bool?
    var default_profile_image: Bool?
    var following: Bool?
    var live_following: Bool?
    var follow_request_sent: Bool?
    var notifications: Bool?
    var muting: Bool?
    var blocking: Bool?
    var blocked_by: Bool?
    var translator_type: String?
    
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id                                      <- map["id"]
        id_str                                  <- map["id_str"]
        name                                    <- map["name"]
        screen_name                             <- map["screen_name"]
        location                                <- map["location"]
        url                                     <- map["url"]
        description                             <- map["description"]
        protected                               <- map["protected"]
        followers_count                         <- map["followers_count"]
        friends_count                           <- map["friends_count"]
        listed_count                            <- map["listed_count"]
        created_at                              <- map["created_at"]
        favourites_count                        <- map["favourites_count"]
        utc_offset                              <- map["utc_offset"]
        time_zone                               <- map["time_zone"]
        geo_enabled                             <- map["geo_enabled"]
        verified                                <- map["verified"]
        statuses_count                          <- map["statuses_count"]
        lang                                    <- map["lang"]
        contributors_enabled                    <- map["contributors_enabled"]
        is_translator                           <- map["is_translator"]
        is_translation_enabled                  <- map["is_translation_enabled"]
        profile_background_color                <- map["profile_background_color"]
        profile_background_image_url            <- map["profile_background_image_url"]
        profile_background_image_url_https      <- map["profile_background_image_url_https"]
        profile_background_tile                 <- map["profile_background_tile"]
        profile_image_url                       <- map["profile_image_url"]
        profile_image_url_https                 <- map["profile_image_url_https"]
        profile_link_color                      <- map["profile_link_color"]
        profile_sidebar_border_color            <- map["profile_sidebar_border_color"]
        profile_sidebar_fill_color              <- map["profile_sidebar_fill_color"]
        profile_text_color                      <- map["profile_text_color"]
        profile_use_background_image            <- map["profile_use_background_image"]
        has_extended_profile                    <- map["has_extended_profile"]
        default_profile                         <- map["default_profile"]
        default_profile_image                   <- map["default_profile_image"]
        following                               <- map["following"]
        live_following                          <- map["live_following"]
        follow_request_sent                     <- map["follow_request_sent"]
        notifications                           <- map["notifications"]
        muting                                  <- map["muting"]
        blocking                                <- map["blocking"]
        blocked_by                              <- map["blocked_by"]
        translator_type                         <- map["translator_type"]
    }
}


class APIError: Mappable {
    var code: Int?
    var message: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        code                    <- map["code"]
        message                 <- map["message"]
    }
}



