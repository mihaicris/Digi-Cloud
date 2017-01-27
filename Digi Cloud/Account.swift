/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A struct for accessing generic password keychain items.
*/

import Foundation
import UIKit.UIImage

struct Account {
    // MARK: Types

    enum AccountError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }

    // MARK: Properties

    private static let service: String = "DigiCloud"

    private static let accessGroup: String? = nil

    private(set) var account: String

    // MARK: Intialization

    init(account: String, accessGroup: String? = nil) {
        self.account = account
    }

    // MARK: Keychain access

    func readToken() throws -> String {
        /*
            Build a query to find the item that matches the service, account and
            access group.
        */
        var query = Account.keychainQuery(account: account)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw AccountError.noPassword }
        guard status == noErr else { throw AccountError.unhandledError(status: status) }

        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String : AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw AccountError.unexpectedPasswordData
        }

        return password
    }

    func save(token: String) throws {
        // Encode the password into an Data object.
        let encodedPassword = token.data(using: String.Encoding.utf8)!

        do {
            // Check for an existing item in the keychain.
            try _ = readToken()

            // Update the existing item with the new password.
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

            let query = Account.keychainQuery(account: account)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw AccountError.unhandledError(status: status) }
        } catch AccountError.noPassword {
            /*
                No password was found in the keychain. Create a dictionary to save
                as a new keychain item.
            */
            var newItem = Account.keychainQuery(account: account)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?

            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw AccountError.unhandledError(status: status) }
        }
    }

    mutating func renameAccount(_ newAccountName: String) throws {
        // Try to update an existing item with the new account name.
        var attributesToUpdate = [String: AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName as AnyObject?

        let query = Account.keychainQuery(account: self.account)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw AccountError.unhandledError(status: status) }

        self.account = newAccountName
    }

    func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = Account.keychainQuery(account: account)
        let status = SecItemDelete(query as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw AccountError.unhandledError(status: status) }
    }

    static func accountItems() throws -> [Account] {
        // Build a query for all items that match the service and access group.
        var query = Account.keychainQuery(accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse

        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else { return [] }

        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw AccountError.unhandledError(status: status) }

        // Cast the query result to an array of dictionaries.
        guard let resultData = queryResult as? [[String : AnyObject]] else { throw AccountError.unexpectedItemData }

        // Create a `KeychainPasswordItem` for each dictionary in the query result.
        var passwordItems = [Account]()
        for result in resultData {
            guard let account  = result[kSecAttrAccount as String] as? String else { throw AccountError.unexpectedItemData }

            let passwordItem = Account(account: account, accessGroup: accessGroup)
            passwordItems.append(passwordItem)
        }

        return passwordItems
    }

    // MARK: Convenience

    private static func keychainQuery(account: String? = nil, accessGroup: String? = nil) -> [String : AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?

        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }

        return query
    }

    func fetchProfileImage(_ completion: @escaping () -> Void ) {
        // Fetch Gravatar profileImages if exist
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: "https://www.gravatar.com/avatar/\(self.account.md5())?s=400&d=404") {
                let cache = Cache()
                if let data = try? Data(contentsOf: url) {
                    // Save in cache profile image
                    cache.save(type: .profile, data: data, for: self.account)
                } else {
                    // Delete cached profile image (if there is any profile image saved)
                    cache.clear(type: .profile, key: self.account)
                }
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }

    func deleteProfileImageFromCache() {
        let cache = Cache()
        cache.clear(type: .profile, key: account)
    }

    func revokeToken() {
        if let token = try? readToken() {
            DispatchQueue.global(qos: .background).async {
                DigiClient.shared.revokeAuthentication(for: token, completion: { statusCode, error in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else if let statusCode = statusCode, statusCode != 204 {
                        print("Status code [API Request -> revoke Token]: \(statusCode) [❗️Warning❗️]")
                    }
                })
            }
        } else {
            print("Could not retrieve a token from Keychain for revoking.")
        }
    }
}
