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
        let view = WKWebView()
        view.navigationDelegate = self
        return view
    }()

    fileprivate let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.progress = 0
        return view
    }()

    private let busyIndicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.hidesWhenStopped = true
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

        setupViews()

        self.title = (self.location.path as NSString).lastPathComponent
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleAction))
        navigationItem.rightBarButtonItem?.isEnabled = false

        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {

        if let node = self.node {
            processFileURL(node: node)
        } else {
            fetchNode()
        }

        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {

        // Close session and delegate
        session?.invalidateAndCancel()
        super.viewWillDisappear(animated)
    }

    // MARK: - Helper Functions

    private func fetchNode() {

        self.busyIndicator.startAnimating()

        DigiClient.shared.fileInfo(atLocation: self.location) { (node, error) in

            self.busyIndicator.stopAnimating()

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

        let key = "\(node.hash!).\(fileExtension)"

        self.fileURL = FileManager.filesCacheDirectoryURL.appendingPathComponent(key)

        if FileManager.default.fileExists(atPath: self.fileURL.path) {
            self.loadFileContent()
        } else {
            self.downloadFile()
        }
    }

    private func downloadFile() {

        // Show progress view
        progressView.isHidden = false
        busyIndicator.startAnimating()

        // Start downloading File
        session = DigiClient.shared.startDownloadFile(at: self.location, delegate: self)
    }

    func handleAction() {
        let controller = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        controller.excludedActivityTypes = nil
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(controller, animated: true, completion: nil)
    }

    private func presentError(message: String, completion: @escaping (UIAlertAction) -> Void) {

        self.busyIndicator.stopAnimating()

        let title = NSLocalizedString("Error", comment: "")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: completion))
        self.present(alertController, animated: true, completion: nil)
    }

    private func setupViews() {
        view.addSubview(webView)
        view.addSubview(progressView)
        view.addSubview(busyIndicator)
        view.addConstraints(with: "H:|[v0]|", views: webView)
        view.addConstraints(with: "V:|[v0]|", views: webView)
        view.addConstraints(with: "H:|[v0]|", views: progressView)
        view.addConstraints(with: "V:|-64-[v0(2)]", views: progressView)
        busyIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        busyIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }

    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    }

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    }

}

extension ContentViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        // avoid memory leak (self cannot be deinitialize because it is a delegate of the session)
        session.invalidateAndCancel()

        // get the downloaded file from temp folder
        do {
            try FileManager.default.moveItem(at: location, to: self.fileURL)

            DispatchQueue.main.async {
                self.loadFileContent()
            }

        } catch {
            print("Could not move file to disk: \(error.localizedDescription)")
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

        UIView.animate(withDuration: 0.5, animations: {
            self.progressView.alpha = 0
        })
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // TODO: Show UIView for Export recommendation
        print(error.localizedDescription)
        self.progressView.alpha = 0
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
