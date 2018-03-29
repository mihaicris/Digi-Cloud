//
//  Logging.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

func DLog<T>(object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG
        let queue = Thread.isMainThread ? "Main (UI)" : "Background"
        print("\n_____________________________________________________")
        print("File:        \((file as NSString).lastPathComponent)")
        print("Function:    \(function)")
        print("Line:        \(line)")
        print("Thread:      \(queue)")
        print("\(object())")
        print("_____________________________________________________\n")
    #endif
}

func addressHeap<T: AnyObject>(object: T) -> String {
    let address = unsafeBitCast(object, to: Int.self)
    return String(format: "%p", address)
}

func INITLog(_ object: AnyObject) {
    print(addressHeap(object: object), "✅", String(describing: type(of: object)))
}

func DEINITLog(_ object: AnyObject) {
    print(addressHeap(object: object), "❌", String(describing: type(of: object)))
}

func logNSError(_ nserror: NSError) {
    print("\n_____________________________________________________\n")
    print("Domain:\t\t\t\t\t\t", nserror.domain)
    print("Code:\t\t\t\t\t\t", nserror.code)
    print("LocalizedDescription:\t\t", nserror.localizedDescription)
    for (index, value) in nserror.userInfo.enumerated() {
        if index == 0 {
            print("\(value.0):\t", "\(value.1)")
        } else if index == 1 {
            print("\(value.0):\t\t", "\(value.1)")
        }
    }
    if let localizedFailureReason = nserror.localizedFailureReason {
        print("Localized Failure Reason:\t", localizedFailureReason)
    }

    if let localizedRecoveryOptions = nserror.localizedRecoveryOptions {
        print("Localized Recovery Options:\t", localizedRecoveryOptions)
    }

    if let localizedRecoverySuggestion = nserror.localizedRecoverySuggestion {
        print("Localized Recovery Suggestion:\t", localizedRecoverySuggestion)
    }
    print("_____________________________________________________\n")
}
