//
//  Constants.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

struct Utils {
    static func getURLFromParameters(path: String, parameters: [String:AnyObject]?) -> URL {
        var components = URLComponents()
        components.scheme = Constants.DigiAPI.Scheme
        components.host = Constants.DigiAPI.Host
        components.path = path

        if parameters != nil {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters! {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }

        return components.url!
    }
}





