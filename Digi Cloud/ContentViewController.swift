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
    
    let fileManager = FileManager.default
    
    var fileUrl: URL!
    
    var webView: WKWebView!
    
    var session: URLSession!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    // View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: self.view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(webView, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Show progress view
        progressView.isHidden = false
        
        // Start downloading File
        session = DigiClient.shared().startFileDownload(delegate: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // close session and delegate
        session.invalidateAndCancel()
        
        //  Delete downloaded file if exists
        deleteDocumentsFolder()
        
        // Remove file from current path
        DigiClient.shared().currentPath.removeLast()
    }
  
    fileprivate func deleteDocumentsFolder() {
        
        // get the Documents Folder in the user space
        let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // delete all content of the Documents directory
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            for url in directoryContents {
                try fileManager.removeItem(at: url)
            }
        } catch {
            print("Could not delete the content of Documents folder: \(error.localizedDescription)")
        }
    }
    
    deinit {
        print("Deinit: ContentViewController")
    }
}

extension ContentViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        // avoid memory leak (self cannot be deinitialize because it is a delegate of the session
        session.invalidateAndCancel()
        
        // get the Documents Folder in the user space
        let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // get the file name from current path
        let fileName: String = DigiClient.shared().currentPath.last!.components(separatedBy: "/").last!
        
        // create destination file url
        self.fileUrl = documentsUrl.appendingPathComponent(fileName)
        
        // get the downloaded file from temp folder
        do {
            try fileManager.moveItem(at: location, to: self.fileUrl)
            
            // load downloded file in the view
            DispatchQueue.main.async {
                self.progressView.isHidden = true
                self.webView.loadFileURL(self.fileUrl, allowingReadAccessTo: self.fileUrl)
            }
        } catch let error {
            print("Could not move file to disk: \(error.localizedDescription)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        // calculate the progress value
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

        // Update the progress on screen
        DispatchQueue.main.async {
            self.progressView.progress = progress
        }
    }
}

extension ContentViewController: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
}



