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
    
    var token: String!
    
    var mount: String!
    
    var url: URL!
    
    @IBOutlet var webView: UIView! = nil
    
    // View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let contentView = WKWebView(frame: self.view.bounds)
        self.view = contentView
        
        var request = URLRequest(url: url)

        request.addValue("Token " + token, forHTTPHeaderField: "Authorization")
        
        contentView.load(request)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        (webView as? WKWebView)?.evaluateJavaScript("location.reload();", completionHandler: nil)
    }
}
