//
//  AppSecurity.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 05/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import Foundation

struct AppSecurity {

    // Temporary variable
    private static var debug_Accounts: [String: String] = {

        var dict: [String: String] = [:]

        /*
         Temporary hardcoded data in file `Accounts.json` in main Bundle
         {
         "email_address": "<email_address>",
         "token": "<token>"
         }
         */

        let filePath = Bundle.main.path(forResource: "Accounts", ofType: "json")!
        let fileURL = URL(fileURLWithPath: filePath)

        let data = try! Data.init(contentsOf: fileURL)

        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            print("Eroare serializare JSON")
            return [:]
        }
        guard let accountsDict = json as? [String: String] else {
            print("Eroare cast")
            return [:]
        }
        for account in accountsDict {
            dict[account.key] = account.value
        }
        return dict

    }()

    static func getToken(account: String) -> String? {

        // TODO: Get this from KeyChain Security
          return debug_Accounts[account]
    }

}
