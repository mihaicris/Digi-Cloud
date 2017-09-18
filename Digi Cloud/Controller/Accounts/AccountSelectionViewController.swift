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
        let attributedText = NSMutableAttributedString(string: "Cloud",
                                                       attributes: [NSAttributedStringKey.font: UIFont(name: "PingFangSC-Semibold", size: 48) as Any])
        let word = NSLocalizedString("for", comment: "")

        attributedText.append(NSAttributedString(string: "\n\(word)  ",
            attributes: [NSAttributedStringKey.font: UIFont(name: "Didot-Italic", size: 20) as Any]))

        attributedText.append(NSAttributedString(string: "Digi Storage",
                                                 attributes: [NSAttributedStringKey.font: UIFont(name: "PingFangSC-Semibold", size: 20) as Any]))

        let nsString = NSString(string: attributedText.string)
        let nsRange = nsString.range(of: "Storage")
        attributedText.addAttributes([NSAttributedStringKey.foregroundColor: color], range: nsRange)

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
        super.viewDidLoad()
        collectionView.register(AccountCollectionCell.self,
                                forCellWithReuseIdentifier: String(describing: AccountCollectionCell.self))
        getPersistedUsers()
        setupViews()
        configureViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAccountsFromKeychain()
    }

    private func getPersistedUsers() {

        users.removeAll()

        do {
            accounts = try Account.accountItems()
        } catch {
            AppSettings.showErrorMessageAndCrash(
                title: NSLocalizedString("Error fetching accounts from Keychain", comment: ""),
                subtitle: NSLocalizedString("The app will now close", comment: "")
            )
        }

        for account in accounts {
            if let user = AppSettings.getPersistedUserInfo(userID: account.userID) {
                users.append(user)
            } else {
                account.revokeToken()
                do {
                    try account.deleteItem()
                } catch {
                    AppSettings.showErrorMessageAndCrash(
                        title: NSLocalizedString("Error deleting account from Keychain", comment: ""),
                        subtitle: NSLocalizedString("The app will now close", comment: "")
                    )
                }
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AccountCollectionCell.self),
                                                            for: indexPath) as? AccountCollectionCell else {
                                                                return UICollectionViewCell()
        }

        let user = users[indexPath.item]
        cell.accountNameLabel.text = "\(user.firstName) \(user.lastName)"

        let cache = Cache()

        if let data = cache.load(type: .profile, key: user.id + ".png") {
            cell.profileImage.image = UIImage(data: data, scale: UIScreen.main.scale)
        } else {
            cell.profileImage.image = #imageLiteral(resourceName: "default_profile_image")
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

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

        view.backgroundColor = UIColor.iconColor

        view.addSubview(logoBigLabel)
        view.addSubview(noAccountsLabel)
        view.addSubview(collectionView)
        view.addSubview(spinner)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            logoBigLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            NSLayoutConstraint(item: logoBigLabel, attribute: .centerY, relatedBy: .equal,
                               toItem: view, attribute: .bottom, multiplier: 0.15, constant: 0.0),

            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            NSLayoutConstraint(item: collectionView, attribute: .height, relatedBy: .equal,
                               toItem: view, attribute: .height, multiplier: 0.5, constant: 0.0),

            spinner.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),

            NSLayoutConstraint(item: spinner, attribute: .centerY, relatedBy: .equal,
                               toItem: collectionView, attribute: .centerY, multiplier: 1.25, constant: 0.0),

            noAccountsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noAccountsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            stackView.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.bounds.height * 0.035)
            ])

    }

    func configureViews() {

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
            self?.configureViews()
        }

        present(controller, animated: true, completion: nil)
    }

    @objc private func handleManageAccounts() {

        let controller = ManageAccountsViewController(controller: self)

        controller.onAddAccount = { [weak self] in
            self?.handleShowLogin()
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
            AppSettings.showErrorMessageAndCrash(
                title: NSLocalizedString("Error fetching accounts from Keychain", comment: ""),
                subtitle: NSLocalizedString("The app will now close", comment: "")
            )
        }

        updateUsers {
            self.configureViews()
        }

    }

    func updateUsers(completion: (() -> Void)?) {

        var updateError = false

        let dispatchGroup = DispatchGroup()

        var updatedUsers: [User] = []

        for account in accounts {

            guard let token = try? account.readToken() else {
                AppSettings.showErrorMessageAndCrash(
                    title: NSLocalizedString("Error reading account from Keychain", comment: ""),
                    subtitle: NSLocalizedString("The app will now close", comment: "")
                )
                return
            }

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
        }

        dispatchGroup.notify(queue: .main) {

            if updateError {
                // Shouwd we inform user about refresh failed?
                // self.showError()
            } else {
                self.users = self.users.updating(from: updatedUsers)
                completion?()
            }
        }
    }

    private func showError(message: String) {

        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                      message: message,
                                      preferredStyle: .alert)

        let actionOK = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            UIView.animate(withDuration: 0.5, animations: {

                let indexPathOneElement = IndexPath(item: 0, section: 0)
                if let cell = self.collectionView.cellForItem(at: indexPathOneElement) {
                    cell.transform = CGAffineTransform.identity
                }
            }, completion: { _ in
                self.getPersistedUsers()
                self.setupViews()
                self.configureViews()
                self.isExecuting = false
            })
        }

        alert.addAction(actionOK)

        self.present(alert, animated: false, completion: nil)
    }

    private func switchToAccount(_ userIndexPath: IndexPath) {

        let user = users[userIndexPath.item]

        // get indexPaths of all users except the one selected
        let indexPaths = users.enumerated().flatMap({ (arg) -> IndexPath? in
            let (offset, element) = arg
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

                let animationClosure = { cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) }

                let animationCompletionClosure: (Bool) -> Void = { _ in

                    self.spinner.startAnimating()

                    DispatchQueue.main.async {
                        let account = Account(userID: user.id)

                        guard let token = try? account.readToken() else {
                            AppSettings.showErrorMessageAndCrash(
                                title: NSLocalizedString("Error reading account from Keychain", comment: ""),
                                subtitle: NSLocalizedString("The app will now close", comment: "")
                            )
                            return
                        }

                        // Try to access network
                        DigiClient.shared.getUser(forToken: token) { _, error in

                            guard error == nil else {

                                self.spinner.stopAnimating()

                                var message: String

                                switch error! {

                                case NetworkingError.internetOffline(let errorMessage), NetworkingError.requestTimedOut(let errorMessage):

                                    message = errorMessage

                                    if !AppSettings.allowsCellularAccess {
                                        let alert = UIAlertController(title: NSLocalizedString("Info", comment: ""),
                                                                      message: NSLocalizedString("Would you like to use cellular data?", comment: ""),
                                                                      preferredStyle: .alert)

                                        let noAction = UIAlertAction(title: "No", style: .default) { _ in
                                            self.showError(message: message)
                                        }

                                        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                                            AppSettings.allowsCellularAccess = true
                                            DigiClient.shared.renewSession()
                                            self.switchToAccount(userIndexPath)
                                        }

                                        alert.addAction(noAction)
                                        alert.addAction(yesAction)

                                        self.present(alert, animated: true, completion: nil)
                                        return
                                    }

                                case AuthenticationError.login:
                                    message = NSLocalizedString("Your session has expired, please log in again.", comment: "")

                                    do {
                                        try account.deleteItem()
                                    } catch {
                                        AppSettings.showErrorMessageAndCrash(
                                            title: NSLocalizedString("Error deleting account from Keychain", comment: ""),
                                            subtitle: NSLocalizedString("The app will now close", comment: "")
                                        )
                                    }

                                default:
                                    message = NSLocalizedString("An error has occurred.\nPlease try again later!", comment: "")
                                }

                                self.showError(message: message)

                                return
                            }

                            // save the Token for current session
                            DigiClient.shared.loggedAccount = account

                            // Save in Userdefaults this user as logged in
                            AppSettings.loggedUserID = user.id

                            DigiClient.shared.getSecuritySettings()

                            // Show account locations
                            self.onSelect?()
                        }
                    }
                }

                UIView.animate(withDuration: 0.3, delay: 0,
                               usingSpringWithDamping: 0.3,
                               initialSpringVelocity: 0.5,
                               options: UIViewAnimationOptions.curveEaseInOut,
                               animations: animationClosure,
                               completion: animationCompletionClosure)
            }
        }

        // Animate the selected account in the collection view
        self.collectionView.performBatchUpdates(updatesClosure, completion: completionClosure)
    }
}
