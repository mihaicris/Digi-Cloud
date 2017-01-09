//
//  AccountSelectionViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 03/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class AccountSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties

    fileprivate let cellId = "Cell"

    var onSelect: (() -> Void)?

    fileprivate var accounts = [Account]()

    fileprivate var accountsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.layer.cornerRadius = 10
        cv.layer.masksToBounds = true
        return cv
    }()

    fileprivate let noAccountsLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor.init(red: 161/255, green: 168/255, blue: 209/255, alpha: 1.0)
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

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()

        accountsCollectionView.register(AccountCell.self, forCellWithReuseIdentifier: cellId)
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSavedAccounts()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        accountsCollectionView.collectionViewLayout.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? AccountCell else {
            return UICollectionViewCell()
        }
        cell.account = accounts[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let flowLayout = (collectionViewLayout as! UICollectionViewFlowLayout)
        let cellSpacing = flowLayout.minimumInteritemSpacing
        let cellWidth = flowLayout.itemSize.width
        let cellCount = CGFloat(collectionView.numberOfItems(inSection: section))
        let collectionViewWidth = collectionView.bounds.size.width
        let totalCellWidth = cellCount * cellWidth
        let totalCellSpacing = cellSpacing * (cellCount - 1)
        let totalCellsWidth = totalCellWidth + totalCellSpacing
        let edgeInsets = (collectionViewWidth - totalCellsWidth) / 2.0
        return edgeInsets > 0 ? UIEdgeInsets(top: 0, left: edgeInsets, bottom: 0, right: edgeInsets) : UIEdgeInsets(top: 0, left: cellSpacing, bottom: 0, right: cellSpacing)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 100
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let account = accounts[indexPath.item]
        do {
            DigiClient.shared.token = try account.readToken()
        } catch {
            fatalError("Cannot load the token from the Keychain.")
        }
        AppSettings.loggedAccount = account.account
        self.onSelect?()
    }

    // MARK: - Helper Functions

    fileprivate func setupViews() {

        accountsCollectionView.delegate = self
        accountsCollectionView.dataSource = self

        setNeedsStatusBarAppearanceUpdate()

        view.backgroundColor = UIColor.init(red: 40/255, green: 78/255, blue: 55/255, alpha: 1.0)

        view.addSubview(logoBigLabel)
        view.addSubview(stackView)
        view.addSubview(noAccountsLabel)
        view.addSubview(accountsCollectionView)
        stackView.addArrangedSubview(signUpLabel)

        NSLayoutConstraint.activate([
            logoBigLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            NSLayoutConstraint(item: logoBigLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 0.15, constant: 0.0),
            accountsCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            accountsCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            NSLayoutConstraint(item: accountsCollectionView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: accountsCollectionView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.37, constant: 0.0),
            noAccountsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noAccountsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            stackView.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.bounds.height * 0.035)
        ])

        updateVisibility()
    }

    fileprivate func updateVisibility() {
        if accounts.count == 0 {
            stackView.removeArrangedSubview(loginToAnotherAccountButton)
            stackView.insertArrangedSubview(addAccountButton, at: 0)
            accountsCollectionView.isHidden = true
            noAccountsLabel.isHidden = false
            addAccountButton.isHidden = false
            loginToAnotherAccountButton.isHidden = true
        } else {
            stackView.removeArrangedSubview(addAccountButton)
            stackView.insertArrangedSubview(loginToAnotherAccountButton, at: 0)
            accountsCollectionView.isHidden = false
            noAccountsLabel.isHidden = true
            addAccountButton.isHidden = true
            loginToAnotherAccountButton.isHidden = false
        }
    }

    @objc fileprivate func handleShowLogin(_: AnyObject) {
        let controller = LoginViewController()
        controller.modalPresentationStyle = .formSheet

        controller.onCancel = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        controller.onSuccess = { [weak self] in
            self?.dismiss(animated: true) {
                self?.onSelect?()
            }
        }

        present(controller, animated: true, completion: nil)
    }

    @objc fileprivate func handleSelectAccount() {

        self.onSelect?()
    }

    fileprivate func getSavedAccounts() {
        /*
         Make sure the collection view is up-to-date by first reloading the
         acocunts items from the keychain and then reloading the table view.
         */
        do {
            accounts = try Account.accountItems()
        } catch {
            fatalError("Error fetching account items - \(error)")
        }
        updateVisibility()
        accountsCollectionView.reloadData()
    }
}
