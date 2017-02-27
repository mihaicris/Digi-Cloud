//
//  ShareLinkViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class ShareLinkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // MARK: - Properties

    var onFinish: (() -> Void)?

    private let linkType: LinkType
    
    private var node: Node

    private var originalHash: String
    private var isSaving: Bool = false

    private lazy var tableView: UITableView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        let t = UITableView(frame: frame, style: .grouped)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.delegate = self
        t.dataSource = self
        return t
    }()

    let baseLinkLabel: UILabelWithPadding = {
        let l = UILabelWithPadding(paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        l.textAlignment = .left
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()

    private lazy var hashTextField: URLHashTextField = {
        let tv = URLHashTextField()
        tv.delegate = self
        return tv
    }()

    private lazy var saveHashButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        b.addTarget(self, action: #selector(handleSaveShortURL), for: .touchUpInside)
        b.alpha = 0
        return b
    }()

    private let enablePasswordSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.isOn = true
        sw.addTarget(self, action: #selector(handleEnablePassword(_:)), for: .valueChanged)
        return sw
    }()

    private let passwordLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()

    private lazy var passwordResetButton: UIButton = {
        let b = UIButton(type: .system)
        b.tintColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        b.setImage(#imageLiteral(resourceName: "Refresh_icon").withRenderingMode(.alwaysTemplate), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        return b
    }()

    private let validityLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()

    private let validityChangeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Change", comment: ""), for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        b.addTarget(self, action: #selector(handleChangeValidity), for: .touchUpInside)
        return b
    }()

    private lazy var validityButtonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private var animating: Bool = false

    // MARK: - Initializers and Deinitializers

    init(node: Node, linkType: LinkType) {

        self.node = node
        self.linkType = linkType

        switch linkType {
        case .download:
            self.originalHash = node.downloadLink?.hash ?? ""
        case .upload:
            self.originalHash = node.uploadLink?.hash ?? ""
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        setupViews()
        setupNavigationItems()
        setupToolBarItems()
        addViewTapGestureRecognizer()
    }

    override func viewWillAppear(_ animated: Bool) {
        requestLink()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let headerTitle: String

        switch section {
        case 0:
            headerTitle = NSLocalizedString("LINK", comment: "")
        case 1:
            headerTitle = NSLocalizedString("PASSWORD", comment: "")
        case 2:
            headerTitle = NSLocalizedString("VALIDITY", comment: "")
        default:
            fatalError("Wrong section index")
        }

        return headerTitle
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0:
            // LINK

            cell.contentView.addSubview(baseLinkLabel)
            cell.contentView.addSubview(hashTextField)
            cell.contentView.addSubview(saveHashButton)

            NSLayoutConstraint.activate([
                baseLinkLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                baseLinkLabel.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),

                saveHashButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                saveHashButton.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),

                hashTextField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                hashTextField.trailingAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                hashTextField.heightAnchor.constraint(equalToConstant: 30),
                hashTextField.leadingAnchor.constraint(equalTo: baseLinkLabel.trailingAnchor)
            ])

        case 1:
            // PASSWORD

            cell.contentView.addSubview(passwordLabel)
            cell.contentView.addSubview(passwordResetButton)
            cell.contentView.addSubview(enablePasswordSwitch)

            NSLayoutConstraint.activate([
                passwordLabel.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
                passwordLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                passwordResetButton.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 90),
                passwordResetButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                enablePasswordSwitch.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                enablePasswordSwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])

        case 2:
            // VALIDITY

            cell.contentView.addSubview(validityLabel)
            cell.contentView.addSubview(validityChangeButton)

            NSLayoutConstraint.activate([
                validityLabel.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
                validityLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                validityChangeButton.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                validityChangeButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])

        default:
            fatalError("Wrong section index")
        }

        return cell
    }

    // MARK: - UItextFieldDelegate Conformance

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor(red: 217/255, green: 239/255, blue: 173/255, alpha: 1.0)

    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        saveHashButton.alpha = 0.0
        textField.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if !isSaving {
            hashTextField.text = originalHash
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // Disable Save hash button if necessary
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let newHash = textFieldText.replacingCharacters(in: range, with: string)

        if newHash.characters.count == 0 || newHash == originalHash || hasInvalidCharacters(name: newHash) {
            saveHashButton.alpha = 0.0
        } else {
            saveHashButton.alpha = 1.0
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if saveHashButton.alpha == 1.0 {
            handleSaveShortURL()
            return true
        } else {
            return false
        }
    }

    // MARK: - Helper Functions

    private func setupViews() {

        tableView.alwaysBounceVertical = false

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        setupTableViewHeaderView()
    }

    private func setupTableViewHeaderView() {

        let frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 85)
        let headerView = UIImageView(frame: frame)
        headerView.image = #imageLiteral(resourceName: "shareBackground")
        headerView.contentMode = .scaleAspectFit

        let code: String = (linkType == .download ) ? "\u{f0ee}" : "\u{f01a}"

        let iconLabel: UILabel = {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.attributedText = NSAttributedString(string: String(code),
                                                  attributes: [NSFontAttributeName: UIFont.fontAwesome(size: 58),
                                                               NSForegroundColorAttributeName: UIColor.defaultColor.withAlphaComponent(0.3)])
            return l
        }()

        headerView.addSubview(iconLabel)

        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        tableView.tableHeaderView = headerView
    }

    private func setupNavigationItems() {

        if linkType == .download {
            self.title = NSLocalizedString("Download Link", comment: "")
        } else {
            self.title = NSLocalizedString("Upload Link", comment: "")
        }

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        navigationItem.setRightBarButton(doneButton, animated: false)
    }

    private func setupToolBarItems() {
        let sendButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleSend))
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        let deleteButton: UIBarButtonItem = {
            let v = UIButton(type: UIButtonType.system)
            v.setTitle(NSLocalizedString("Delete Link", comment: ""), for: .normal)
            v.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
            v.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .disabled)
            v.setTitleColor(.red, for: .normal)
            v.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            v.sizeToFit()
            let b = UIBarButtonItem(customView: v)
            return b
        }()

        self.navigationController?.isToolbarHidden = false
        self.setToolbarItems([deleteButton, flexibleButton, sendButton], animated: false)

    }

    private func addViewTapGestureRecognizer() {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(handleCancelChangeShortURL))
        self.view.addGestureRecognizer(tgr)
    }

    private func hasInvalidCharacters(name: String) -> Bool {
        let charset = CharacterSet.init(charactersIn: name)
        return !charset.isDisjoint(with: CharacterSet.alphanumerics.inverted)
    }

    @objc private func handleDone() {
        onFinish?()
    }

    @objc private func handleSend() {
        // TODO: Implement
    }

    @objc private func handleSaveShortURL() {

        isSaving = true

        guard let hash = hashTextField.text else {
            print("No hash")
            return
        }

        DigiClient.shared.setLinkCustomShortUrl(node: self.node, type: self.linkType, hash: hash) { _, error in

            guard error == nil else {

                if let error = error as? NetworkingError {
                    if case NetworkingError.wrongStatus(_) = error {
                        let title = NSLocalizedString("Error", comment: "")
                        let message = NSLocalizedString("Sorry, this short URL is not available.", comment: "")
                        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in self.isSaving = false })
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    print(error!.localizedDescription)
                }

                return
            }
            self.isSaving = false
            self.originalHash = hash
            self.saveHashButton.alpha = 0.0
            self.hashTextField.resignFirstResponder()
        }
    }

    @objc private func handleCancelChangeShortURL() {
        hashTextField.text = self.originalHash
        self.hashTextField.resignFirstResponder()
    }

    @objc private func handleDelete() {

        DigiClient.shared.deleteLink(node: self.node, type: self.linkType) { (error) in
            guard error == nil else {
                print("Error at deletion of the link.")
                return
            }

            self.onFinish?()
        }

    }

    @objc private func handleEnablePassword(_ sender: UISwitch) {

        if sender.isOn {
            self.handleResetPassword()
        } else {
            DigiClient.shared.removeLinkPassword(node: self.node, type: linkType) { (link, error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }

                self.node.updateNode(with: link)
                self.updateValues(from: link)
            }
        }
    }

    @objc private func handleResetPassword() {

        startSpinning()

        DigiClient.shared.setOrResetLinkPassword(node: self.node, type: linkType, completion: { (link, error) in

            self.stopSpinning()

            guard error == nil else {
                print(error!.localizedDescription)
                return
            }

            self.node.updateNode(with: link)
        })
    }

    @objc private func handleChangeValidity() {
        // TODO: Implement
    }

    private func requestLink() {

        DigiClient.shared.getLink(for: self.node, type: self.linkType) { (link, error) in

            guard error == nil else {
                print(error!.localizedDescription)
                return
            }

            self.node.updateNode(with: link)
            self.updateValues(from: link)
        }
    }

    private func updateValues(from link: Link?) {

        guard let link = link  else {
            print("Nothing to do.")
            return
        }
            
        baseLinkLabel.text = String("\(link.host)/")
        hashTextField.text = link.hash
        originalHash = link.hash
        
        if let password = link.password {
            passwordLabel.text = password
            enablePasswordSwitch.isOn = true
            passwordResetButton.alpha = 1.0
        } else {
            passwordLabel.text =  NSLocalizedString("The link is public", comment: "")
            enablePasswordSwitch.isOn = false
            passwordResetButton.alpha = 0.0
        }
        

    }

    private func startSpinning() {
        if(!animating) {
            animating = true
            spinWithOptions(options: .curveEaseIn)
        }
    }

    private func stopSpinning() {
        animating = false
    }

    func spinWithOptions(options: UIViewAnimationOptions) {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: options, animations: { () -> Void in
            let val: CGFloat = CGFloat(Double.pi)
            self.passwordResetButton.transform = self.passwordResetButton.transform.rotated(by: val)
        }) { (finished: Bool) -> Void in
            if(finished) {
                if(self.animating) {
                    self.spinWithOptions(options: .curveLinear)
                } else if (options != .curveEaseOut) {
                    self.spinWithOptions(options: .curveEaseOut)
                } else {
                    let link: Link? = self.linkType == .download ? self.node.downloadLink : self.node.uploadLink
                    self.updateValues(from: link)
                }
            }
        }
    }
}
