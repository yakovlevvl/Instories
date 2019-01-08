//
//  UserService.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 1/6/19.
//  Copyright © 2019 Vladyslav Yakovlev. All rights reserved.
//

import Foundation

final class UserService {

    static func getUsers(with username: String, completion: @escaping ([User]) -> ()) {
        let urlString = "https://i.instagram.com/web/search/topsearch/?query=\(username)"
        
        guard let url = urlString.url else {
            return completion([])
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? Json else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            guard let usersJson = json["users"] as? [Json] else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            var users = [User]()
            
            for userJson in usersJson {
                guard let userDict = userJson["user"] as? Json else {
                    return DispatchQueue.main.async {
                        completion([])
                    }
                }
                
                guard let username = userDict["username"] as? String, let avatarUrlStr = userDict["profile_pic_url"] as? String, let avatarUrl = avatarUrlStr.url, let id = userDict["pk"] as? String else {
                    return DispatchQueue.main.async {
                        completion([])
                    }
                }
                
                let user = User(id: id, username: username, avatarUrl: avatarUrl)
                users.append(user)
            }
            
            DispatchQueue.main.async {
                completion(users)
            }
            
        }.resume()
    }
}
