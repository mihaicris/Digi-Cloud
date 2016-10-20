//
//  ActionsViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 20/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class ActionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    let v: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate func setupViews() {
        
        view.addSubview(v)
        
        view.addConstraints(with: "H:|[v0]|", views: v)
        view.addConstraints(with: "V:|[v0]|", views: v)
    }

}
