//
//  ContentViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 23/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit
import WebKit

final class ContentViewController: UIViewController {

    // MARK: - Properties

    let location: Location

    var node: Node?

    var fileURL: URL!
    var session: URLSession?

    private lazy var webView: WKWebView = {
        let v = WKWebView()
        v.navigationDelegate = self
        return v
    }()

    fileprivate let progressView: UIProgressView = {
        let v = UIProgressView(progressViewStyle: .default)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.progress = 0
        return v
    }()

    fileprivate let handImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "hand"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    fileprivate let noPreviewImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "no_preview"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    fileprivate let noPreviewLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = NSLocalizedString("No Preview Available", comment: "")
        l.font = UIFont.HelveticaNeueMedium(size: 16)
        return l
    }()

    fileprivate let noPreviewMessageLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = NSLocalizedString("This file type can't be viewed.", comment: "")
        l.font = UIFont.HelveticaNeue(size: 14)
        l.textColor = UIColor.gray
        return l
    }()

    fileprivate let busyIndicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.hidesWhenStopped = true
        i.startAnimating()
        i.activityIndicatorViewStyle = .gray
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()

    // MARK: - Initializers and Deinitializers

    init(location: Location) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
        INITLog(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        self.title = (self.location.path as NSString).lastPathComponent
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleAction))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let node = self.node {
            processFileURL(node: node)
        } else {
            fetchNode()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Close session
        session?.invalidateAndCancel()
        navigationController?.hidesBarsOnTap = false
    }

    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    // MARK: - Helper Functions

    private func setupViews() {
        view.backgroundColor = .white
    }

    private func fetchNode() {

        DigiClient.shared.fileInfo(atLocation: self.location) { (node, error) in

            guard error == nil else {

                var message: String

                switch error! {

                case NetworkingError.internetOffline(let msg), NetworkingError.requestTimedOut(let msg):
                    message = msg
                default:
                    message = NSLocalizedString("An error has occured, please try again later.", comment: "")
                }

                self.presentError(message: message) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
                return
            }

            if let node = node {
                self.processFileURL(node: node)
            }
        }
    }

    fileprivate func loadFileContent() {

        // Add WKWebView
        view.addSubview(webView)
        view.addConstraints(with: "H:|[v0]|", views: webView)
        view.addConstraints(with: "V:|[v0]|", views: webView)

        // load file in the view
        self.webView.loadFileURL(self.fileURL, allowingReadAccessTo: self.fileURL)

        // enable right bar button for exporting
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

    private func processFileURL(node: Node) {

        let fileName = node.name
        var fileExtension = (fileName as NSString).pathExtension

        // For WKWebView to try to open files without extension, we assume they are text.

        if fileExtension.characters.isEmpty {
            fileExtension = "txt"
        }

        let key: String
        if let hash = node.hash {
            key = "\(hash).\(fileExtension)"
        } else {
            key = "TEMPORARY.\(fileExtension)"
        }

        self.fileURL = FileManager.filesCacheFolderURL.appendingPathComponent(key)

        if node.hash != nil {
            if FileManager.default.fileExists(atPath: self.fileURL.path) {
                self.loadFileContent()
            } else {
                self.downloadFile()
            }
        } else {

            if FileManager.default.fileExists(atPath: self.fileURL.path) {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    return
                }
            }
            self.downloadFile()
        }
    }

    private func downloadFile() {

        view.addSubview(progressView)
        view.addSubview(busyIndicator)

        NSLayoutConstraint.activate([
            progressView.leftAnchor.constraint(equalTo: view.leftAnchor),
            progressView.rightAnchor.constraint(equalTo: view.rightAnchor),
            progressView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2.0),

            busyIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            busyIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // Start downloading File
        session = DigiClient.shared.startDownloadFile(at: self.location, delegate: self)
    }

    @objc private func handleAction() {

        handleFileNotOpen(isVisible: false)

        let controller = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        controller.excludedActivityTypes = nil
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(controller, animated: true, completion: nil)
    }

    fileprivate func presentError(message: String, completion: @escaping (UIAlertAction) -> Void) {
        let title = NSLocalizedString("Error", comment: "")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: completion))
        self.present(alertController, animated: true, completion: nil)
    }

    fileprivate func handleFileNotOpen(isVisible: Bool) {

        if isVisible {

            webView.removeFromSuperview()
            view.addSubview(noPreviewImageView)
            view.addSubview(noPreviewLabel)
            view.addSubview(noPreviewMessageLabel)

            NSLayoutConstraint.activate([

                noPreviewImageView.bottomAnchor.constraint(equalTo: noPreviewLabel.topAnchor, constant: -20),
                noPreviewImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                noPreviewLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
                noPreviewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                noPreviewMessageLabel.topAnchor.constraint(equalTo: noPreviewLabel.bottomAnchor, constant: 10),
                noPreviewMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)

            ])

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.view.addSubview(self.handImageView)
                self.handImageView.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 110).isActive = true
                self.handImageView.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.rightAnchor, constant: -50).isActive = true

                let initialPosition = self.handImageView.center
                let endPosition = CGPoint(x: initialPosition.x + 20, y: initialPosition.y - 20)

                UIView.animate(withDuration: 1.2,
                               delay: 0.3,
                               options: [.autoreverse, .repeat],
                               animations: {
                                    self.handImageView.center = endPosition
                               },
                               completion: nil)
            }

        } else {
            handImageView.removeFromSuperview()
        }
    }
}

extension ContentViewController: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        DispatchQueue.main.async {
            // avoid memory leak (self cannot be deinitialize because it is a delegate of the session)
            session.invalidateAndCancel()

            // Stop the spinner
            self.busyIndicator.stopAnimating()

            guard error == nil else {

                if (error! as NSError).code != -999 {

                    // If not cancelled
                    self.presentError(message: error!.localizedDescription) { (_) in
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }

                return
            }

            // Load the file in WKWebView
            self.loadFileContent()
        }
    }

    fileprivate func removeProgressView() {

        UIView.animate(withDuration: 0.5, animations: {
            self.progressView.alpha = 0.0

        }) { _ in
            self.progressView.removeFromSuperview()
        }
    }
}

extension ContentViewController: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        // get the downloaded file from temp folder
        do {
            try FileManager.default.moveItem(at: location, to: self.fileURL)

        } catch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                let message = NSLocalizedString("There was an error at saving the file. Try again later or reinstall the app.", comment: "")

                self.presentError(message: message) { _ in
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        // calculate the progress value
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

        // Update the progress on screen
        DispatchQueue.main.async {
            self.progressView.setProgress(progress, animated: true)
        }
    }
}

extension ContentViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        removeProgressView()
        navigationController?.hidesBarsOnTap = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        removeProgressView()
        navigationController?.hidesBarsOnTap = false
        handleFileNotOpen(isVisible: true)
    }
}
