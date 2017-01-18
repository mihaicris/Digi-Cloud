//
//  FileManager+DigiCloud.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 23/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation.NSFileManager

extension FileManager {

    class func documentsDir() -> URL {
        return self.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    }

    class func cachesDir() -> URL {
        return self.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    class func createFilesFolder() {

        // create the custom folder path
        let filesURL = documentsDir().appendingPathComponent("files")
        let path = filesURL.path

        if !self.default.fileExists(atPath: path) {
           do {
                try self.default.createDirectory(atPath: path,
                                                 withIntermediateDirectories: false,
                                                 attributes: nil)
           } catch {
                print("Error creating files folder in documents dir: \(error)")
           }
        }
    }

}
