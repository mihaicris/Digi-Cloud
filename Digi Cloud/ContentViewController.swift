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
    
    var session: URLSession!

    // View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Show progress view
        progressView.isHidden = false

        //  Delete downloaded file if exists
        deleteDocumentsFolder()
        
        // Start downloading File
        session = DigiClient.shared().startFileDownload(delegate: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // close session and delegate
        session.invalidateAndCancel()
        
        // Remove file from current path
        DigiClient.shared().currentPath.removeLast()
    }
    
    
    fileprivate lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        return view
    }()

    fileprivate let progressView: UIProgressView = {
       let view = UIProgressView(progressViewStyle: .default)
        view.progress = 0
        return view
    }()
    
    private func setupViews() {
        view.addSubview(webView)
        view.addSubview(progressView)
        view.addConstraints(with: "H:|[v0]|", views: webView)
        view.addConstraints(with: "V:|[v0]|", views: webView)
        view.addConstraints(with: "H:|[v0]|", views: progressView)
        view.addConstraints(with: "V:|-64-[v0(2)]", views: progressView)
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
//        return
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
            

            DispatchQueue.main.async {

                // load downloded file in the view
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
            self.progressView.setProgress(progress, animated: true)
        }
    }
}

extension ContentViewController: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
}

extension ContentViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
        UIView.animate(withDuration: 0.5, animations: {
            self.progressView.alpha = 0
        })
    }
    
}
