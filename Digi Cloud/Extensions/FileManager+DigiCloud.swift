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

    static var profileImagesCacheFolderURL: URL {
        return documentsDir().appendingPathComponent(CacheFolders.Profiles)
    }

    static var filesCacheFolderURL: URL {
        return documentsDir().appendingPathComponent(CacheFolders.Files)
    }

    static func createProfileImagesCacheFolder() {
        createFolder(at: profileImagesCacheFolderURL)
    }

    static func createFilesCacheFolder() {
        createFolder(at: filesCacheFolderURL)
    }

    static func deleteProfileImagesCacheFolder() {
        deleteFolder(at: profileImagesCacheFolderURL)
    }

    static func deleteFilesCacheFolder() {
        deleteFolder(at: filesCacheFolderURL)
    }

    static func emptyProfileImagesCache() {
        deleteFilesCacheFolder()
        createFilesCacheFolder()
    }

    static func emptyFilesCache() {
        deleteFilesCacheFolder()
        createFilesCacheFolder()
    }

    static func createFolder(at url: URL) {
        guard self.default.fileExists(atPath: url.path) == false else { return }
        do {
            try self.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }

    static func deleteFolder(at url: URL) {
        try? self.default.removeItem(at: url)
    }

    static func sizeOfFolder(at url: URL) -> UInt64 {

        guard self.default.fileExists(atPath: url.path) else { return 0 }

        guard let enumerator = self.default.enumerator(atPath: url.path) else { return 0 }

        var size: UInt64 = 0

        enumerator.forEach {

            guard let name = $0 as? String else { return }

            let path = url.appendingPathComponent(name).path

            guard let attributes = try? self.default.attributesOfItem(atPath: path) as NSDictionary else {
                AppSettings.showErrorMessageAndCrash(
                    title: NSLocalizedString("Error accessing files on device.", comment: ""),
                    subtitle: NSLocalizedString("The app will now close", comment: "")
                )
                return
            }

            size += attributes.fileSize()
        }

        return size

    }

    static func sizeOfFilesCacheFolder() -> UInt64 {
        return sizeOfFolder(at: filesCacheFolderURL)
    }

}
