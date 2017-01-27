//
    //  FileManager+DigiCloud.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 23/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation.NSFileManager

extension FileManager {

    static func documentsDir() -> URL {
        return self.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    }

    static var profileImagesCacheDirectory: URL {
        return documentsDir().appendingPathComponent(CacheFolders.Profiles)
    }

    static var filesCacheDirectory: URL {
        return documentsDir().appendingPathComponent(CacheFolders.Files)
    }

    static func createProfileImagesCacheDirectory() {
        createDirectory(at: profileImagesCacheDirectory)
    }

    static func createFilesCacheDirectory() {
        createDirectory(at: filesCacheDirectory)
    }

    static func deleteProfileImagesCacheDirectory() {
        deleteDirectory(at: profileImagesCacheDirectory)
    }

    static func deleteFilesCacheDirectory() {
        deleteDirectory(at: profileImagesCacheDirectory)
    }

    static func createDirectory(at url: URL) {
        guard self.default.fileExists(atPath: url.path) == false else { return }
        do {
            try self.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
            fatalError()
        }
    }

    static func deleteDirectory(at url: URL) {
        do {
            try self.default.removeItem(at: url)
        } catch {
            print(error.localizedDescription)
            fatalError()
        }
    }

}
