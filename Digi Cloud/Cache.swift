//
//  CacheStorage.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import Foundation
import UIKit.UIImage

enum CacheType {
    case file
    case profile
}

final class Cache {

    func load(type: CacheType, key: String) -> Data? {
        var url = FileManager.documentsDir()
        switch type {
        case .file:
            url = url.appendingPathComponent(CacheFolders.Files)
        case .profile:
            url = url.appendingPathComponent(CacheFolders.Profiles)
        }
        url = url.appendingPathComponent(key)
        return try? Data(contentsOf: url)
    }

    func save(type: CacheType, data: Data, for key: String) {
        var url = FileManager.documentsDir()
        switch type {
        case .file:
            url = url.appendingPathComponent(CacheFolders.Files)
        case .profile:
            url = url.appendingPathComponent(CacheFolders.Profiles)
        }
        url = url.appendingPathComponent(key)
        try? data.write(to: url)
    }

    func clear(type: CacheType, key: String) {
        var url = FileManager.documentsDir()
        switch type {
        case .file:
            url = url.appendingPathComponent(CacheFolders.Files)
        case .profile:
            url = url.appendingPathComponent(CacheFolders.Profiles)
        }
        url = url.appendingPathComponent(key)
        try? FileManager.default.removeItem(at: url)
    }
}
