//
//  Logging.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

public func DLog<T>( object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG
        let queue = Thread.isMainThread ? "Main (UI)" : "Background"
        print("===================================================")
        print("File:     \(file.components(separatedBy: "/").last!)")
        print("Function: \(function)")
        print("Line:     \(line)")
        print("Thread:   \(queue)")
        print("Object:   \(object())")
    #endif
}
