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

    static func cachesDir() -> URL {
        return self.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    static func createPersistentCacheFolders() {
        let urls = [
            documentsDir().appendingPathComponent(CacheFolders.Files),
            documentsDir().appendingPathComponent(CacheFolders.Profiles)
        ]
        for url in urls {
            let path = url.path
            if !self.default.fileExists(atPath: path) {
                do {
                    try self.default.createDirectory(atPath: path,
                                                     withIntermediateDirectories: false,
                                                     attributes: nil)
                } catch {
                    print("Error creating folder \(url.lastPathComponent) in documents dir: \(error)")
                }
            }
        }
    }
}
