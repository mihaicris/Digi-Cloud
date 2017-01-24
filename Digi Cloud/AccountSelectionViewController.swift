//
//  AccountSelectionViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 03/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class AccountSelectionViewController: UIViewController,
                                      UICollectionViewDelegate, UICollectionViewDataSource,
                                      UICollectionViewDelegateFlowLayout {
    // MARK: - Properties

    fileprivate let cellId = "Cell"
    let cellWidth: CGFloat = 200
    let cellHeight: CGFloat = 100
    let spacingHoriz: CGFloat = 20
    let spacingVert: CGFloat = 20

    private var isExecuting = false

    var onSelect: (() -> Void)?

    fileprivate var accounts = [Account]()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.activityIndicatorViewStyle = .white
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    fileprivate var accountsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.layer.cornerRadius = 25
        cv.layer.masksToBounds = true
        cv.backgroundColor = UIColor.init(white: 0.0, alpha: 0.05)
        return cv
    }()

    fileprivate let noAccountsLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 161/255, green: 168/255, blue: 209/255, alpha: 1.0)
        l.text = NSLocalizedString("No accounts", comment: "Label, information")
        l.font = UIFont(name: "HelveticaNeue-light", size: 30)
        return l
    }()

    fileprivate let addAccountButton: UIButton = {
        let b = UIButton(type: UIButtonType.system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Add Account", comment: "Button Title"), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        b.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return b
    }()

    fileprivate let stackView: UIStackView = {
        let st = UIStackView()
        st.translatesAutoresizingMaskIntoConstraints = false
        st.axis = .horizontal
        st.distribution = .fillEqually
        st.spacing = 50
        return st
    }()

    fileprivate let signUpLabel: UIButton = {
        let b = UIButton(type: UIButtonType.system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Sign Up for Digi Storage", comment: "Button Title"), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        return b
    }()

    fileprivate let loginToAnotherAccountButton: UIButton = {
        let b = UIButton(type: UIButtonType.system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Log in to Another Account", comment: "Button Title"), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        b.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return b
    }()

    fileprivate let logoBigLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 3
        let color = UIColor.init(red: 48/255, green: 133/255, blue: 243/255, alpha: 1.0)
        let attributedText = NSMutableAttributedString(string: "Digi Cloud",
                                                       attributes: [NSFontAttributeName: UIFont(name: "PingFangSC-Semibold", size: 48) as Any])
        let word = NSLocalizedString("for", comment: "a word")
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

    fileprivate let manageAccountsButton: UIButton = {
        let b = UIButton(type: UIButtonType.system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Manage Accounts", comment: "Button Title"), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        b.addTarget(self, action: #selector(handleManageAccounts), for: .touchUpInside)
        return b
    }()

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        accountsCollectionView.register(AccountCollectionCell.self, forCellWithReuseIdentifier: cellId)
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAccountsFromKeychain()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let layout = accountsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? AccountCollectionCell else {
            return UICollectionViewCell()
        }
        let cache = Cache()
        let account = accounts[indexPath.item]
        cell.accountLabel.text = account.account
        if let data = cache.load(type: .profile, key: account.account) {
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

        guard !isExecuting else { return }
        isExecuting = true

        self.activityIndicatorView.startAnimating()

        let account = accounts[indexPath.item]
        do {
            DigiClient.shared.token = try account.readToken()
        } catch {
            fatalError("Cannot load the token from the Keychain.")
        }
        AppSettings.loggedAccount = account.account

        self.accounts.removeAll()
        self.accounts.append(account)
        collectionView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.onSelect?()
        }

    }

    // MARK: - Helper Functions

    fileprivate func setupViews() {

        accountsCollectionView.delegate = self
        accountsCollectionView.dataSource = self

        setNeedsStatusBarAppearanceUpdate()

        view.backgroundColor = UIColor.init(red: 40/255, green: 78/255, blue: 65/255, alpha: 1.0)

        view.addSubview(logoBigLabel)
        view.addSubview(noAccountsLabel)
        view.addSubview(accountsCollectionView)
        view.addSubview(activityIndicatorView)
        view.addSubview(stackView)
        stackView.addArrangedSubview(signUpLabel)

        NSLayoutConstraint.activate([
            logoBigLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            NSLayoutConstraint(item: logoBigLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 0.15, constant: 0.0),
            accountsCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            accountsCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            NSLayoutConstraint(item: accountsCollectionView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: accountsCollectionView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.5, constant: 0.0),
            activityIndicatorView.centerXAnchor.constraint(equalTo: accountsCollectionView.centerXAnchor),
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: accountsCollectionView, attribute: .centerY, multiplier: 1.25, constant: 0.0),
            noAccountsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noAccountsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            stackView.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.bounds.height * 0.035)
        ])

        configureOtherViews()
    }

    fileprivate func configureOtherViews() {
        if accounts.count == 0 {
            loginToAnotherAccountButton.removeFromSuperview()
            manageAccountsButton.removeFromSuperview()
            stackView.insertArrangedSubview(addAccountButton, at: 0)
            accountsCollectionView.isHidden = true
            noAccountsLabel.isHidden = false
        } else {
            addAccountButton.removeFromSuperview()
            stackView.insertArrangedSubview(loginToAnotherAccountButton, at: 0)
            stackView.insertArrangedSubview(manageAccountsButton, at: 0)
            accountsCollectionView.isHidden = false
            noAccountsLabel.isHidden = true
            loginToAnotherAccountButton.isHidden = false
        }
    }

    @objc fileprivate func handleShowLogin() {
        let controller = LoginViewController()
        controller.modalPresentationStyle = .formSheet

        controller.onCancel = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        controller.onSuccess = { [weak self] in
            self?.dismiss(animated: true) {
                self?.fetchAccountsFromKeychain()
            }
        }
        present(controller, animated: true, completion: nil)
    }

    @objc fileprivate func handleManageAccounts() {
        let controller = ManageAccountsViewController(accounts: accounts)
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .popover
        navController.popoverPresentationController?.sourceView = manageAccountsButton
        navController.popoverPresentationController?.sourceRect = manageAccountsButton.bounds
        present(navController, animated: true, completion: nil)
    }

    func fetchAccountsFromKeychain() {
        /*
         Make sure the collection view is up-to-date by first reloading the
         acocunts items from the keychain and then reloading the table view.
         */
        do {
            accounts = try Account.accountItems()
        } catch {
            fatalError("Error fetching account items - \(error)")
        }
        configureOtherViews()

        if accounts.count == 0 {
            dismiss(animated: true, completion: nil)
        }

        for account in accounts {
            account.fetchProfileImage()
        }
        accountsCollectionView.reloadData()
    }
}
