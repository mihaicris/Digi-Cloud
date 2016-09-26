//
//  DigiClient.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 26/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

// Singleton class for DIGI Client

class DigiClient {
    
    // MARK: - Properties
    
    var token: String? = nil
    
    // Shared Session
    var session: URLSession = URLSession.shared
    
    // MARK: - Initializers
    
    init() {}
    
    // MAKR: - Shared instance
    class func sharedInstance() -> DigiClient {
        struct Singleton {
            static var sharedInstance = DigiClient()
        }
        return Singleton.sharedInstance
    }
    
    
    // MARK: - GET 
    func taskForGETMethod() -> URLSessionDataTask {
        
        let url = URL(string: "www.google.com")!
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
        }
        return task
    }
    
    // MARK: - POST
    func taskForPOSTMethod() -> URLSessionDataTask {
        
        let url = URL(string: "www.google.com")!
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
        }
        return task
    }
    
    // MARK: - DELETE
    func taskForDELETEMethod() -> URLSessionDataTask {
        
        let url = URL(string: "www.google.com")!
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
        }
        return task
    }
    
}
