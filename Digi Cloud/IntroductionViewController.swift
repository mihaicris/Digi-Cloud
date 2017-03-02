//
//  IntroductionViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 05/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController {

    // MARK: - Properties

    var onFinish: (() -> Void)?

    // MARK: - Initializers and Deinitializers

    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .magenta
        setupViews()

        AppSettings.setDefaultAppSettings()
    }

    override func viewDidAppear(_ animated: Bool) {

        // Exit the Intro screen after 2 seconds (temporary functionality)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.onFinish?()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Helper Functions

    private func setupViews() {
        let label: UILabel = {
            let l = UILabel()
            l.text = "Introduction"
            l.textColor = .white
            l.font = UIFont(name: "Helvetica", size: 48)
            l.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            l.sizeToFit()
            l.center = view.center
            return l
        }()

        view.addSubview(label)
    }

}
