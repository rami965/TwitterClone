//
//  BackendManager.swift
//  TwitterClient
//
//  Created by MACC on 3/7/18.
//  Copyright © 2018 Rami. All rights reserved.
//

import Foundation
import Alamofire

class BackendManager: NSObject {
    /**
     Fetches a list of followers.
     
     - parameters:
        - client: The client auth data.
        - url: Fetching URL.
        - params: Request parameters.
        - completion: Returns the fetched list object.
     */
    func fetchFollowersListFromAPI(_ client: OAuthClient, _ url: String, _ params: [String: String], completion: @escaping (FollowersResponse?, Error?)->()) {
        
        Alamofire.request(client.makeRequest(.GET, url: url, parameters: params)).responseObject { (response: DataResponse<FollowersResponse>) in
            
            switch response.result {
            case .success(let JSON):
                completion(JSON, nil)
                
            case .failure(let error):
                completion(nil, error)
            }
            
        }
    }
    
    /**
     Fetches a list of tweets.
     
     - parameters:
         - client: The client auth data.
         - url: Fetching URL.
         - params: Request parameters.
         - completion: Returns the fetched list array.
     */
    func fetchTweetsListFromAPI(_ client: OAuthClient, _ url: String, _ params: [String: String], completion: @escaping ([TweetsResponse]?, Error?)->()) {
        
        Alamofire.request(client.makeRequest(.GET, url: url, parameters: params)).responseArray { (response: DataResponse<[TweetsResponse]>) in
            
            switch response.result {
            case .success(let JSON):
                completion(JSON, nil)
                
            case .failure(let error):
                completion(nil, error)
            }
            
            }.responseString { (response) in
                if let val = response.result.value {
                    print(val)
                }
        }
    }
}
