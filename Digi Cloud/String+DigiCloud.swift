//
//  String+DigiCloud.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 18/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import Foundation

extension String {
    func md5() -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format: "%02x", byte)
        }
        return hexString
    }
}
