//
//  AccountSelectionViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 03/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class AccountSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
                                            UICollectionViewDelegateFlowLayout {

    // MARK: - Properties

    private let cellId = "Cell"
    let cellWidth: CGFloat = 200
    let cellHeight: CGFloat = 100
    let spacingHoriz: CGFloat = 20
    let spacingVert: CGFloat = 20

    private var isExecuting = false

    var onSelect: (() -> Void)?

    var accounts: [Account] = []
    var users: [User] = []

    private let spinner: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.activityIndicatorViewStyle = .white
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = UIColor.init(white: 0.0, alpha: 0.05)
        return cv
    }()

    private let noAccountsLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 161/255, green: 168/255, blue: 209/255, alpha: 1.0)
        l.text = NSLocalizedString("No accounts", comment: "")
        l.font = UIFont.HelveticaNeueLight(size: 30)
        return l
    }()

    private let addAccountButton: UIButton = {
        let b = UIButton(type: UIButtonType.system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Add Account", comment: ""), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.HelveticaNeue(size: 14)
        b.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return b
    }()

    private let stackView: UIStackView = {
        let st = UIStackView()
        st.translatesAutoresizingMaskIntoConstraints = false
        st.axis = .horizontal
        st.distribution = .fillEqually
        st.spacing = 50
        return st
    }()

    private let loginToAnotherAccountButton: UIButton = {
        let b = UIButton(type: UIButtonType.system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Log in to Another Account", comment: ""), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.HelveticaNeue(size: 14)
        b.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return b
    }()

    private let logoBigLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 3
        let color = UIColor.init(red: 48/255, green: 133/255, blue: 243/255, alpha: 1.0)
        let attributedText = NSMutableAttributedString(string: "Digi Cloud",
                                                       attributes: [NSFontAttributeName: UIFont(name: "PingFangSC-Semibold", size: 48) as Any])
        let word = NSLocalizedString("for", comment: "")

        attributedText.append(NSAttributedString(string: "\n\(word)  ",
                                                 attributes: [NSFontAttributeName: UIFont(name: "Didot-Italic", size: 20) as Any]))

        attributedText.append(NSAttributedString(string: "Digi Storage",
                                                 attributes: [NSFontAttributeName: UIFont(name: "PingFangSC-Semibold", size: 20) as Any]))

        let nsString = NSString(string: attributedText.string)
        var nsRange = nsString.range(of: "Cloud")
        attributedText.addAttributes([NSForegroundColorAttributeName: color], range: nsRange)
        nsRange = nsString.range(of: "Storage")
        attributedText.addAttributes([NSForegroundColorAttributeName: color], range: nsRange)

        l.attributedText = attributedText
        return l
    }()

    private let manageAccountsButton: UIButton = {
        let b = UIButton(type: UIButtonType.system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Manage Accounts", comment: ""), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.HelveticaNeue(size: 14)
        b.addTarget(self, action: #selector(handleManageAccounts), for: .touchUpInside)
        return b
    }()

    // MARK: - Initializers and Deinitializers

    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {

        collectionView.register(AccountCollectionCell.self, forCellWithReuseIdentifier: cellId)
        getPersistedUsers()
        setupViews()
        updateViews()

        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateUsers {
            self.updateViews()
        }
    }

    private func getPersistedUsers() {

        users.removeAll()

        do {
            accounts = try Account.accountItems()
        } catch {
            fatalError("Error fetching accounts from Keychain - \(error)")
        }

        for account in accounts {
            if let user = AppSettings.getPersistedUserInfo(userID: account.userID) {
                users.append(user)
            } else {
                fatalError("Error fetching persisted user from UserDefaults")
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? AccountCollectionCell else {
            return UICollectionViewCell()
        }
        let cache = Cache()

        let user = users[indexPath.item]

        if let user = AppSettings.getPersistedUserInfo(userID: user.id) {
            cell.accountNameLabel.text = user.name
        }

        if let data = cache.load(type: .profile, key: user.id + ".png") {
            cell.profileImage.image = UIImage(data: data)
        } else {
            cell.profileImage.image = #imageLiteral(resourceName: "DefaultAccountProfileImage")
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return UIEdgeInsets.zero
        }

        let colWidth = collectionView.bounds.width
        let colHeight = collectionView.bounds.height

        var topInset, leftInset, bottomInset, rightInset: CGFloat

        let items = CGFloat(collectionView.numberOfItems(inSection: section))

        layout.minimumInteritemSpacing = spacingHoriz
        layout.minimumLineSpacing = spacingVert

        switch items {
        case 1:
            topInset = (colHeight - cellHeight)/2
            leftInset = (colWidth - cellWidth)/2
        case 2:
            topInset = (colHeight - cellHeight)/2
            leftInset = (colWidth - (cellWidth * 2) - spacingHoriz)/2
        case 3:
            topInset = (colHeight - (cellHeight * 3) - (spacingVert * 2))/2
            leftInset = (colWidth - cellWidth)/2
        case 4:
            topInset = (colHeight - (cellHeight * 2) - (spacingVert * 1))/2
            leftInset = (colWidth - (cellWidth * 2) - (spacingHoriz * 1))/2
        default:
            topInset = (colHeight - (cellHeight * 3) - (spacingVert * 2))/2
            leftInset = (colWidth - (cellWidth * 2) - (spacingHoriz * 1))/2
        }

        bottomInset = topInset
        rightInset = leftInset

        return UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // Prevents a second selection
        guard !isExecuting else { return }
        isExecuting = true

        switchToAccount(indexPath)
    }

    // MARK: - Helper Functions

    private func setupViews() {

        collectionView.delegate = self
        collectionView.dataSource = self

        setNeedsStatusBarAppearanceUpdate()

        view.backgroundColor = UIColor.init(red: 40/255, green: 78/255, blue: 65/255, alpha: 1.0)

        view.addSubview(logoBigLabel)
        view.addSubview(noAccountsLabel)
        view.addSubview(collectionView)
        view.addSubview(spinner)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            logoBigLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            NSLayoutConstraint(item: logoBigLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 0.15, constant: 0.0),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            NSLayoutConstraint(item: collectionView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.5, constant: 0.0),
            spinner.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            NSLayoutConstraint(item: spinner, attribute: .centerY, relatedBy: .equal, toItem: collectionView, attribute: .centerY, multiplier: 1.25, constant: 0.0),
            noAccountsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noAccountsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            stackView.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.bounds.height * 0.035)
        ])

    }

    func updateViews() {

        if users.count == 0 {
            loginToAnotherAccountButton.removeFromSuperview()
            manageAccountsButton.removeFromSuperview()
            stackView.insertArrangedSubview(addAccountButton, at: 0)
            collectionView.isHidden = true
            noAccountsLabel.isHidden = false
        } else {
            addAccountButton.removeFromSuperview()
            stackView.insertArrangedSubview(loginToAnotherAccountButton, at: 0)
            stackView.insertArrangedSubview(manageAccountsButton, at: 0)
            collectionView.isHidden = false
            noAccountsLabel.isHidden = true
            loginToAnotherAccountButton.isHidden = false
        }

        collectionView.reloadData()
    }

    @objc private func handleShowLogin() {
        let controller = LoginViewController()
        controller.modalPresentationStyle = .formSheet

        controller.onSuccess = { [weak self] user in
            self?.getPersistedUsers()
            self?.updateViews()
        }

        present(controller, animated: true, completion: nil)
    }

    @objc private func handleManageAccounts() {

        let controller = ManageAccountsViewController(controller: self)

        controller.onAddAccount = { [weak self] in
            self?.handleShowLogin()
        }

        controller.onFinish = { [weak self] in
            self?.getAccountsFromKeychain()
        }

        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .popover
        navController.popoverPresentationController?.sourceView = manageAccountsButton
        navController.popoverPresentationController?.sourceRect = manageAccountsButton.bounds
        present(navController, animated: true, completion: nil)
    }

    func getAccountsFromKeychain() {
        /*
         Make sure the collection view is up-to-date by first reloading the
         acocunts items from the keychain and then reloading the table view.
         */
        do {
            accounts = try Account.accountItems()
        } catch {
            fatalError("Error fetching account from Keychain - \(error)")
        }

        updateUsers {
            self.updateViews()
        }

    }

    func updateUsers(completion: (() -> Void)?) {

        var updateError = false

        let dispatchGroup = DispatchGroup()

        var updatedUsers: [User] = []

        for account in accounts {

            do {
                let token = try account.readToken()

                dispatchGroup.enter()

                AppSettings.saveUser(forToken: token) { user, error in

                    dispatchGroup.leave()

                    guard error == nil else {
                        updateError = true
                        return
                    }

                    if let user = user {
                        updatedUsers.append(user)
                    }
                }

            } catch {
                fatalError("Error fetching account from Keychain - \(error)")
            }
        }

        dispatchGroup.notify(queue: .main, execute: {

            if updateError {
                // Shouwd we inform user about refresh failed?
                // self.showError()
            } else {
                self.users = self.users.updating(from: updatedUsers)
                completion?()
            }
        })
    }

    private func showError(message: String) {

        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)

        let completion = { (alert: UIAlertAction) in

            self.reverseAnimation {
                self.getPersistedUsers()
                self.setupViews()
                self.updateViews()
                self.isExecuting = false

            }
        }

        let actionOK = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: completion)

        alert.addAction(actionOK)

        self.present(alert, animated: false, completion: nil)
    }

    private func switchToAccount(_ userIndexPath: IndexPath) {

        let user = users[userIndexPath.item]

        // get indexPaths of all users except the one selected
        let indexPaths = users.enumerated().flatMap({ (offset, element) -> IndexPath? in
            if element.id == user.id {
                return nil
            }
            return IndexPath(item: offset, section: 0)
        })

        self.users.removeAll()
        users.append(user)

        let updatesClosure: () -> Void = {
            self.collectionView.deleteItems(at: indexPaths)
        }

        let completionClosure: (Bool) -> Void = { _ in

            let indexPathOneElement = IndexPath(item: 0, section: 0)

            if let cell = self.collectionView.cellForItem(at: indexPathOneElement) {

                let animationClosure = { cell.transform = CGAffineTransform(scaleX: 1.4, y: 1.4) }

                let animationCompletionClosure: (Bool) -> Void = { _ in

                    self.spinner.startAnimating()

                    DispatchQueue.main.async {
                        let account = Account(userID: user.id)

                        // read token
                        let token = try! account.readToken()

                        // Try to access network
                        DigiClient.shared.getUser(forToken: token) { _, error in

                            guard error == nil else {

                                self.spinner.stopAnimating()

                                var message: String

                                switch error! {

                                case NetworkingError.internetOffline(let errorMessage), NetworkingError.requestTimedOut(let errorMessage):
                                    message = errorMessage
                                    break

                                case AuthenticationError.login:
                                    message = NSLocalizedString("Your session has expired, please log in again.", comment: "")
                                    try! account.deleteItem()
                                default:
                                    message = NSLocalizedString("An error has occurred.\nPlease try again later!", comment: "")
                                    break
                                }

                                DispatchQueue.main.async {
                                    self.showError(message: message)
                                }

                                return
                            }

                            // save the Token for current session
                            DigiClient.shared.loggedAccount = account

                            // Save in Userdefaults this user as logged in
                            AppSettings.loggedUserID = user.id

                            // Show account locations
                            self.onSelect?()
                        }
                    }
                }

                UIView.animate(withDuration: 0.5, delay: 0,
                               usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 1,
                               options: UIViewAnimationOptions.curveEaseInOut,
                               animations: animationClosure,
                               completion: animationCompletionClosure)
            }
        }

        // Animate the selected account in the collection view
        self.collectionView.performBatchUpdates(updatesClosure, completion: completionClosure)
    }

    private func reverseAnimation(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, animations: {

            let indexPathOneElement = IndexPath(item: 0, section: 0)
            if let cell = self.collectionView.cellForItem(at: indexPathOneElement) {
                    cell.transform = CGAffineTransform.identity
            }
        }, completion: { _ in
            completion()
        })
    }
}
