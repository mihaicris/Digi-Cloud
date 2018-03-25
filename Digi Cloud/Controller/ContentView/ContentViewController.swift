//
//  ContentViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 23/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit
import WebKit
import PDFKit

final class ContentViewController: UIViewController {

    // MARK: - Properties

    internal var node: Node?

    // MARK: - Initializers

    init(location: Location) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Properties

    private let location: Location
    private var fileURL: URL!
    private var session: URLSession?

    private lazy var pdfView: PDFView = {
        let v = PDFView()
        v.displayMode = .singlePageContinuous
        v.autoScales = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var webView: WKWebView = {
        let v = WKWebView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.navigationDelegate = self
        return v
    }()

    private let progressView: UIProgressView = {
        let v = UIProgressView(progressViewStyle: .default)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.progress = 0
        return v
    }()

    private let handImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "hand"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let noPreviewImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "no_preview"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let noPreviewLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = NSLocalizedString("No Preview Available", comment: "")
        l.font = UIFont.fontHelveticaNeueMedium(size: 16)
        return l
    }()

    private let noPreviewMessageLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = NSLocalizedString("This file type can't be viewed.", comment: "")
        l.font = UIFont.fontHelveticaNeue(size: 14)
        l.textColor = UIColor.gray
        return l
    }()

    private let busyIndicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.hidesWhenStopped = true
        i.startAnimating()
        i.activityIndicatorViewStyle = .gray
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
}

// MARK: - UIVIewController Methods

extension ContentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.node != nil {
            processNode()
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
}

// MARK: - Target-Action Methods

private extension ContentViewController {

    @objc func handleExportButtonTouched() {
        handImageView.isHidden = true

        // check if inputs are available
        guard let url = fileURL, let fileName = node?.name else { return }

        // prepare a file url by replacing the hash name with the actual file name

        let exportFolderURL = FileManager.filesCacheFolderURL.appendingPathComponent("Export", isDirectory: true)
        FileManager.deleteFolder(at: exportFolderURL)
        FileManager.createFolder(at: exportFolderURL)

        let exportFileURL = exportFolderURL.appendingPathComponent(fileName)

        do {
            try FileManager.default.copyItem(at: url, to: exportFileURL)
        } catch {
            return
        }

        let controller = UIActivityViewController(activityItems: [exportFileURL], applicationActivities: nil)
        controller.excludedActivityTypes = nil
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(controller, animated: true, completion: nil)
    }

}

// MARK: - Delegate Conformance

extension ContentViewController: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            // avoid memory leak (self cannot be deinitialize because it is a delegate of the session)
            session.invalidateAndCancel()

            guard error == nil else {
                if (error! as NSError).code != -999 {
                    // If not cancelled
                    self.presentError(message: error!.localizedDescription) { (_) in
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
                return
            }
            self.loadFileContent()
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
        fileTypeCanNotBeOpen(isVisible: true)
    }

}

// MARK: - Private Methods

private extension ContentViewController {

    func setupViews() {
        view.backgroundColor = .white
        self.title = (self.location.path as NSString).lastPathComponent
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleExportButtonTouched))
        navigationItem.rightBarButtonItem?.isEnabled = false

    }

    func fetchNode() {
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
                self.node = node
                self.processNode()
            }
        }
    }

    func loadFileContent() {
        if node?.contentType == "application/pdf" {

            removeProgressView()
            busyIndicator.stopAnimating()
            navigationController?.hidesBarsOnTap = false

            view.addSubview(pdfView)
            NSLayoutConstraint.activate([
                pdfView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                pdfView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                pdfView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
                pdfView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
            guard let pdfDocument = PDFDocument(url: self.fileURL) else {
                fileTypeCanNotBeOpen(isVisible: true)
                return
            }
            navigationController?.hidesBarsOnTap = true
            pdfView.document = pdfDocument
        } else {
            view.addSubview(webView)
            NSLayoutConstraint.activate([
                webView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                webView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                webView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
                webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
            self.webView.loadFileURL(self.fileURL, allowingReadAccessTo: self.fileURL)
        }

        // enable right bar button for exporting
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

    func processNode() {

        guard let fileName = self.node?.name else {
            return
        }
        var fileExtension = (fileName as NSString).pathExtension

        // For WKWebView to try to open files without extension, we assume they are text.

        if fileExtension.isEmpty {
            fileExtension = "txt"
        }

        let key: String
        if let hash = self.node?.hash, !hash.isEmpty {
            key = "\(hash).\(fileExtension)"
        } else {
            key = "TEMPORARY.\(fileExtension)"
        }

        self.fileURL = FileManager.filesCacheFolderURL.appendingPathComponent(key)

        if let hash = node?.hash, !hash.isEmpty {
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

    func downloadFile() {
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

    func presentError(message: String, completion: @escaping (UIAlertAction) -> Void) {
        let title = NSLocalizedString("Error", comment: "")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: completion))
        self.present(alertController, animated: true, completion: nil)
    }

    func fileTypeCanNotBeOpen(isVisible: Bool) {
        if isVisible {
            if node?.contentType == "application/pdf" {
                pdfView.removeFromSuperview()
            } else {
                webView.removeFromSuperview()
            }
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

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.view.addSubview(self.handImageView)
                self.handImageView.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 50).isActive = true
                self.handImageView.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.rightAnchor, constant: -70).isActive = true

                let initialPosition = self.handImageView.center
                let endPosition = CGPoint(x: initialPosition.x + 20, y: initialPosition.y - 20)

                UIView.animate(
                    withDuration: 1.2,
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

    func removeProgressView() {
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.progressView.alpha = 0.0
        },
            completion: { _ in
                self.progressView.removeFromSuperview()
        }
        )
    }

}
