//
//  Logging.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

public func DLog<T>(object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
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

func addressHeap<T: AnyObject>(o: T) -> String {
    let address = unsafeBitCast(o, to: Int.self)
    return String(format: "%p", address)
}

public func INITLog(_ object: AnyObject) {
    #if DEBUGCONTROLLERS
        print(addressHeap(o: object), "✅", String(describing: type(of: object)))
    #endif
}

public func DEINITLog(_ object: AnyObject) {
    #if DEBUGCONTROLLERS
        print(addressHeap(o: object), "❌", String(describing: type(of: object)))
    #endif
}

func LogNSError(_ nserror: NSError) {
    print("\n_____________________________________________________\n")
    print("Domain: ", nserror.domain)
    print("Code: ", nserror.code)
    print("LocalizedDescription: ", nserror.localizedDescription, "\n")
    print("LocalizedFailureReason: ", nserror.localizedFailureReason ?? "")
    print("LocalizedRecoveryOption: ", nserror.localizedRecoveryOptions ?? "")
    print("LocalizedRecoverySuggestion: ", nserror.localizedRecoverySuggestion ?? "", "\n")
    for v in nserror.userInfo { print(v.0, ": ", v.1) }
    print("_____________________________________________________\n")
}
