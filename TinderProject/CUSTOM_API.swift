//
//  CUSTOM_API.swift
//  TinderProject
//
//  Created by hkg328 on 8/28/18.
//  Copyright © 2018 HC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class CUSTOM_API {
    static let BASE_URL = "http://localhost:3000"
    
    static let REGISTER_USER = BASE_URL + "/users/register"
    static let UPDATE_SETTING = BASE_URL + "/users/updateSetting"
    static let UPDATE_LOCATION = BASE_URL + "/users/updateLocation"
    
    static let REGISTER_THING = BASE_URL + "/things/register"
    static let MY_AVAILABLE_THINGS = BASE_URL + "/things/getMyThings"
    static let GET_CANDIDATE_THINGS = BASE_URL + "/things/getCandidateThings"
    
    
    
    
    
    public static func getMyAvailableThings(completion: @escaping(_ things: [Thing]) -> Void) {
        let params:[String: Any] = [
            "firebaseId": User.currentUser.id!
        ]
        
        Alamofire.request(CUSTOM_API.MY_AVAILABLE_THINGS, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseJSON { (response) in
                print("this is the response")
                debugPrint(response)
                //                print(response.result)
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    print(json)
                    var things: [Thing] = []
                    for item in json["things"].arrayValue {
                        let thing = Thing(data: item)
                        things.append(thing)
                    }
                    completion(things)
                    break;
                case .failure(let error):
                    debugPrint(error)
                    debugPrint(response.data)
                    completion([])
                }
        }
    }
    
    public static func updateUserSettings(params: [String: Any], completion: @escaping() -> Void) {
        var params1: [String: Any] = params
        params1["firebaseId"] = User.currentUser.id!
        Alamofire.request(CUSTOM_API.UPDATE_SETTING, method: .post, parameters: params1, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseJSON { (response) in
                print("this is the response")
                debugPrint(response)
                //                print(response.result)
                switch response.result {
                case .success(let data):
                    debugPrint(data)
                    completion()
                    break;
                case .failure(let error):
                    debugPrint(error)
                    debugPrint(response.data)
                    completion()
                }
        }
    }
    public static func updateUserLocation(params: [String: Any], completion: @escaping() -> Void) {
        var params1: [String: Any] = params
        params1["firebaseId"] = User.currentUser.id!
        Alamofire.request(CUSTOM_API.UPDATE_LOCATION, method: .post, parameters: params1, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseJSON { (response) in
                debugPrint(response)
                switch response.result {
                case .success(let data):
                    debugPrint(data)
                    completion()
                    break;
                case .failure(let error):
                    debugPrint(error)
                    debugPrint(response.data)
                    completion()
                }
        }
    }
    
    public static func getCandidateItems(completion: @escaping(_ things: [Thing]) -> Void) {
        var params1: [String: Any] = [:]
        params1["firebaseId"] = User.currentUser.id!
        Alamofire.request(CUSTOM_API.GET_CANDIDATE_THINGS, method: .post, parameters: params1, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseJSON { (response) in
                debugPrint(response)
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    print(json)
                    var things: [Thing] = []
                    for item in json["things"].arrayValue {
                        let thing = Thing(data: item)
                        things.append(thing)
                    }
                    completion(things)
                    break;
                case .failure(let error):
                    debugPrint(error)
                    debugPrint(response.data)
                    completion([])
                }
        }
    }
    
    
    
}
