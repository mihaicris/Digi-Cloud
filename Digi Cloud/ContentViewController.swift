//
//  ContentViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 23/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit
import WebKit

class ContentViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var webView: UIView! = nil
    
    // View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentView = WKWebView(frame: self.view.bounds)
        self.view = contentView
        
        let method =  Methods.GetFile.replacingOccurrences(of: "{id}", with: DigiClient.shared().currentMount)
        let parameters = [ParametersKeys.Path: DigiClient.shared().currentPath.last!]
        let url = DigiClient.shared().getURL(method: method, parameters: parameters)
        
        var request = URLRequest(url: url)
        request.addValue("Token " + DigiClient.shared().token, forHTTPHeaderField: "Authorization")
        
        contentView.load(request)
    }
    
    deinit {
        DigiClient.shared().currentPath.removeLast()
    }
}

extension ContentViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {}
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {}
}

extension ContentViewController: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
}



