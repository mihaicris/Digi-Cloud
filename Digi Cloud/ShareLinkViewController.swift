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

    private var node: Node {
        didSet {
            if !isAnimatingReset {
                self.updateValues()
            }
        }
    }

    private var originalLinkHash: String
    private var isSaving: Bool = false
    private var isAnimatingReset: Bool = false

    private lazy var tableView: UITableView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        let t = UITableView(frame: frame, style: .grouped)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.delegate = self
        t.dataSource = self
        return t
    }()

    private var spinner: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.activityIndicatorViewStyle = .gray
        ai.hidesWhenStopped = true
        return ai
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
        b.isHidden = true
        return b
    }()

    private let enablePasswordSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.isOn = true
        sw.addTarget(self, action: #selector(handleEnablePassword(_:)), for: .valueChanged)
        return sw
    }()

    private let uploadNotificationSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.isOn = false
        sw.addTarget(self, action: #selector(handleToggleEmailNotification(_:)), for: .valueChanged)
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

    private let changeValidityButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Change", comment: ""), for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        b.addTarget(self, action: #selector(handleChangeValidity), for: .touchUpInside)
        return b
    }()

    private let saveCustomDateButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        b.addTarget(self, action: #selector(handleSaveCustomDate), for: .touchUpInside)
        b.isHidden = true
        return b
    }()

    private let validityDateAndTimePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.translatesAutoresizingMaskIntoConstraints = false
        dp.locale = .current
        dp.datePickerMode = .dateAndTime
        dp.minuteInterval = 30
        dp.addTarget(self, action: #selector(handleValidateCustomDate(_:)), for: .valueChanged)
        dp.isHidden = true
        return dp
    }()

    private lazy var validitySegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: [
            NSLocalizedString("1 hour", comment: ""),
            NSLocalizedString("1 day", comment: ""),
            NSLocalizedString("1 Month", comment: ""),
            NSLocalizedString("Forever", comment: ""),
            NSLocalizedString("Custom", comment: "")
        ])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: .normal)
        sc.addTarget(self, action: #selector(handleValiditySelectorValueChanged(_:)), for: .valueChanged)
        sc.isHidden = true
        return sc
    }()

    var errorMessageVerticalConstraint: NSLayoutConstraint?

    private lazy var waitingView: UIView = {

        let v = UIView()

        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false

        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.tag = 55
        spinner.startAnimating()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.tag = 99
        label.numberOfLines = 0

        v.addSubview(spinner)
        v.addSubview(label)

        self.errorMessageVerticalConstraint = label.centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: 40)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            label.widthAnchor.constraint(equalTo: v.widthAnchor, multiplier: 0.8),
            self.errorMessageVerticalConstraint!
        ])

        return v
    }()

    private var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.YYY・HH:mm"
        return df
    }()

    // MARK: - Initializers and Deinitializers

    init(node: Node, linkType: LinkType, onFinish: @escaping () -> Void) {

        self.node = node
        self.linkType = linkType
        self.onFinish = onFinish

        switch linkType {
        case .download:
            self.originalLinkHash = node.downloadLink?.hash ?? ""
        case .upload:
            self.originalLinkHash = node.uploadLink?.hash ?? ""
        }

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
        setupTableViewHeaderView()
        setupNavigationItems()
        setupToolBarItems()
        addViewTapGestureRecognizer()
    }

    override func viewWillAppear(_ animated: Bool) {
        requestLink()
        super.viewWillAppear(true)
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

    override func viewWillDisappear(_ animated: Bool) {
        DigiClient.shared.task?.cancel()
        super.viewWillDisappear(animated)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {

        guard section == 0 else { return "" }
        var title: String = ""
        var counter: Int = 0
        if linkType == .download {
            counter = self.node.downloadLink?.counter ?? 0
            title += NSLocalizedString("Views: ", comment: "")
        } else {
            counter = self.node.uploadLink?.counter ?? 0
            title += NSLocalizedString("Received: ", comment: "")
        }
        title += String(counter)
        return title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkType == .upload && section == 0 ? 2 : 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return validityDateAndTimePicker.isHidden == false  && indexPath.section == 2 ? 150 : UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0:
            // LINK

            if indexPath.row == 0 {
                cell.contentView.addSubview(baseLinkLabel)
                cell.contentView.addSubview(hashTextField)
                cell.contentView.addSubview(saveHashButton)

                NSLayoutConstraint.activate([
                    baseLinkLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    baseLinkLabel.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
                    baseLinkLabel.heightAnchor.constraint(equalToConstant: 30),

                    saveHashButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    saveHashButton.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),

                    hashTextField.leadingAnchor.constraint(lessThanOrEqualTo: baseLinkLabel.trailingAnchor, constant: 2),
                    hashTextField.trailingAnchor.constraint(equalTo: saveHashButton.leadingAnchor, constant: -8),
                    hashTextField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    hashTextField.heightAnchor.constraint(equalToConstant: 30)
                ])

                hashTextField.setContentHuggingPriority(249, for: .horizontal)

            } else if linkType == .upload {

                let label: UILabel = {
                    let l = UILabel()
                    l.translatesAutoresizingMaskIntoConstraints = false
                    l.text = NSLocalizedString("Send email when receive files", comment: "")
                    return l
                }()

                cell.contentView.addSubview(label)
                cell.contentView.addSubview(uploadNotificationSwitch)

                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
                    label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    uploadNotificationSwitch.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                    uploadNotificationSwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                    ])
            }

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
            cell.contentView.addSubview(changeValidityButton)
            cell.contentView.addSubview(validitySegmentedControl)
            cell.contentView.addSubview(validityDateAndTimePicker)
            cell.contentView.addSubview(saveCustomDateButton)
            cell.contentView.addSubview(spinner)

            NSLayoutConstraint.activate([
                validityLabel.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
                validityLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                changeValidityButton.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                changeValidityButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                validitySegmentedControl.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
                validitySegmentedControl.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                spinner.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                spinner.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                validityDateAndTimePicker.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
                validityDateAndTimePicker.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                validityDateAndTimePicker.heightAnchor.constraint(equalTo: cell.contentView.heightAnchor),
                saveCustomDateButton.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                saveCustomDateButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])

        default:
            fatalError("Wrong section index")
        }

        return cell
    }

    // MARK: - UItextFieldDelegate Conformance

    func textFieldDidBeginEditing(_ textField: UITextField) {
        setDateAndTimePickerViewVisible(false)
        validityLabel.isHidden = false
        changeValidityButton.isHidden = false
        validitySegmentedControl.isHidden = true
        saveCustomDateButton.isHidden = true
        textField.backgroundColor = UIColor(red: 217/255, green: 239/255, blue: 173/255, alpha: 1.0)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        saveHashButton.isHidden = true
        textField.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if !isSaving {
            hashTextField.text = originalLinkHash
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // Disable Save hash button if necessary
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let newHash = textFieldText.replacingCharacters(in: range, with: string)

        if newHash.characters.count == 0 || newHash == originalLinkHash || hasInvalidCharacters(name: newHash) {
            saveHashButton.isHidden = true
        } else {
            saveHashButton.isHidden = false
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if saveHashButton.isHidden == false {
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
        view.addSubview(waitingView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),

            waitingView.topAnchor.constraint(equalTo: view.topAnchor),
            waitingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            waitingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            waitingView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
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
            self.title = NSLocalizedString("Send Link", comment: "")
        } else {
            self.title = NSLocalizedString("Receive Files", comment: "")
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

        self.setToolbarItems([deleteButton, flexibleButton, sendButton], animated: false)
    }

    private func addViewTapGestureRecognizer() {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(handleCancelChangeShortURL))
        self.view.addGestureRecognizer(tgr)
    }

    private func configureWaitingView(type: WaitingType, message: String) {

        switch type {
        case .hidden:
            waitingView.isHidden = true
            self.navigationController?.setToolbarHidden(false, animated: false)
        case .started, .stopped:
            waitingView.isHidden = false
            self.navigationController?.setToolbarHidden(true, animated: false)
            if let v = waitingView.viewWithTag(55) as? UIActivityIndicatorView {
                if type == .started {
                    v.startAnimating()
                    errorMessageVerticalConstraint?.constant = 40
                } else {
                    v.stopAnimating()
                    errorMessageVerticalConstraint?.constant = 0
                }
            }

            if let v = waitingView.viewWithTag(99) as? UILabel {
                v.text = message
            }
        }
    }

    private func hasInvalidCharacters(name: String) -> Bool {
        let charset = CharacterSet.init(charactersIn: name)
        return !charset.isDisjoint(with: CharacterSet.alphanumerics.inverted)
    }

    @objc private func handleDone() {
        onFinish?()
    }

    @objc private func handleSend() {

        let alink: Link? = linkType == .download ? self.node.downloadLink : self.node.uploadLink

        guard let link = alink else {
            print("No valid link")
            return
        }

        let title = NSLocalizedString("Digi Storage file share", comment: "")
        var content: String

        if linkType == .download {
            content = NSLocalizedString("I am sending you a download link:", comment: "")
        } else {
            content = NSLocalizedString("I am sending you an upload link:", comment: "")
        }

        content += " \(link.shortUrl)\n"

        if let password = link.password {
            content += NSLocalizedString("Password is: ", comment: "")
            content += password
        }

        let controller = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        controller.setValue(title, forKey: "subject")
        controller.excludedActivityTypes = nil
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(controller, animated: true, completion: nil)
    }

    @objc private func handleSaveShortURL() {

        isSaving = true

        guard let hash = hashTextField.text else {
            print("No hash")
            return
        }

        DigiClient.shared.setLinkCustomShortUrl(node: self.node, type: self.linkType, hash: hash) { link, error in

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
            self.originalLinkHash = hash
            self.node.updateNode(with: link)
        }
    }

    @objc private func handleCancelChangeShortURL() {
        hashTextField.text = self.originalLinkHash
        self.hashTextField.resignFirstResponder()
    }

    @objc private func handleDelete() {

        configureWaitingView(type: .started, message: NSLocalizedString("Deleting Link", comment: ""))

        DigiClient.shared.deleteLink(node: self.node, type: self.linkType) { (error) in
            guard error == nil else {
                self.configureWaitingView(type: .stopped, message: NSLocalizedString("There was an error communicating with the network.", comment: ""))
                return
            }
            self.onFinish?()
        }
    }

    @objc private func handleEnablePassword(_ sender: UISwitch) {

        resetAllFields()

        startSpinning()

        if sender.isOn {
            self.handleResetPassword()
        } else {
            DigiClient.shared.removeLinkPassword(node: self.node, type: linkType) { (link, error) in

                guard error == nil else {
                    self.stopSpinning()
                    sender.setOn(true, animated: true)
                    print(error!.localizedDescription)
                    return
                }

                self.node.updateNode(with: link)

                self.stopSpinning()

            }
        }
    }

    @objc private func handleResetPassword() {

        resetAllFields()
        startSpinning()

        DigiClient.shared.setOrResetLinkPassword(node: self.node, type: linkType, completion: { (link, error) in

            guard error == nil else {
                self.stopSpinning()
                print(error!.localizedDescription)
                return
            }

            self.node.updateNode(with: link)
            self.stopSpinning()
        })
    }

    @objc private func handleChangeValidity() {

        resetAllFields()

        validityLabel.isHidden = true
        changeValidityButton.isHidden = true
        validitySegmentedControl.isHidden = false
        validitySegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }

    @objc private func handleValiditySelectorValueChanged(_ sender: UISegmentedControl) {

        var validTo: TimeInterval?
        let calendarComponent: Calendar.Component?

        switch sender.selectedSegmentIndex {
        case 0:
            calendarComponent = .hour
        case 1:
            calendarComponent = .day
        case 2:
            calendarComponent = .month
        case 3:
            calendarComponent = nil
        case 4:
            validitySegmentedControl.isHidden = true
            setDateAndTimePickerViewVisible(true)
            return
        default:
            return
        }

        if let calendarComponent = calendarComponent,
            let date = Calendar.current.date(byAdding: calendarComponent, value: 1, to: Date()) {
            validTo = date.timeIntervalSince1970
        }

        saveCustomValidationDate(validTo: validTo)
    }

    @objc private func handleValidateCustomDate(_ sender: UIDatePicker) {

        let customDate = sender.date
        let minimumDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!

        if customDate < minimumDate {
            saveCustomDateButton.isHidden = true
        } else {
            saveCustomDateButton.isHidden = false
        }
    }

    @objc private func handleSaveCustomDate() {

        let customDate = validityDateAndTimePicker.date
        let validTo = customDate.timeIntervalSince1970

        saveCustomDateButton.isHidden = true

        saveCustomValidationDate(validTo: validTo)
    }

    @objc private func handleToggleEmailNotification(_ sender: UISwitch) {

        resetAllFields()

        DigiClient.shared.setReceiverAlert(sender.isOn, node: self.node) { link, error in

            guard error == nil else {
                sender.setOn(!sender.isOn, animated: true)
                print(error!.localizedDescription)
                return
            }

            self.node.updateNode(with: link)
        }
    }

    private func setDateAndTimePickerViewVisible(_ visible: Bool) {

        if visible {
            validityDateAndTimePicker.minimumDate = Date()
            validityDateAndTimePicker.isHidden = false
        } else {
            validityDateAndTimePicker.isHidden = true
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    private func saveCustomValidationDate(validTo: TimeInterval?) {

        self.spinner.startAnimating()

        DigiClient.shared.setLinkCustomValidity(node: self.node, type: linkType, validTo: validTo) { link, error in

            self.spinner.stopAnimating()

            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            self.resetAllFields()
            self.node.updateNode(with: link)
        }
    }

    private func resetAllFields() {
        hashTextField.resignFirstResponder()
        setDateAndTimePickerViewVisible(false)
        validityLabel.isHidden = false
        changeValidityButton.isHidden = false
        validitySegmentedControl.isHidden = true
    }

    private func requestLink() {

        configureWaitingView(type: .started, message: NSLocalizedString("Preparing Link", comment: ""))

        DigiClient.shared.getLink(for: self.node, type: self.linkType) { (link, error) in

            guard error == nil else {
                self.configureWaitingView(type: .stopped, message: NSLocalizedString("There was an error communicating with the network.", comment: ""))
                return
            }

            self.node.updateNode(with: link)
            self.configureWaitingView(type: .hidden, message: "")
        }
    }

    private func updateValues() {

        guard let link: Link = linkType == .download ? self.node.downloadLink : self.node.uploadLink else {
            print("No valid link found.")
            return
        }

        hashTextField.resignFirstResponder()
        baseLinkLabel.text = String("\(link.host)/")
        hashTextField.text = link.hash
        originalLinkHash = link.hash

        if let password = link.password {
            passwordLabel.text = password
            enablePasswordSwitch.isOn = true
            passwordResetButton.isHidden = false
        } else {
            passwordLabel.text =  NSLocalizedString("The link is public", comment: "")
            enablePasswordSwitch.isOn = false
            passwordResetButton.isHidden = true
        }

        if let validTo = link.validTo {
            let date = Date(timeIntervalSince1970: validTo / 1000)
            validityLabel.text = dateFormatter.string(from: date)
        } else {
            validityLabel.text = NSLocalizedString("Link has no expiration date", comment: "")
        }

        waitingView.isHidden = true
    }

    private func startSpinning() {
        if(!isAnimatingReset) {
            isAnimatingReset = true
            spinWithOptions(options: .curveEaseIn)
        }
    }

    private func stopSpinning() {
        isAnimatingReset = false
    }

    func spinWithOptions(options: UIViewAnimationOptions) {
        UIView.animate(withDuration: 0.5, delay: 0, options: options, animations: { () -> Void in
            let val: CGFloat = CGFloat(Double.pi)
            self.passwordResetButton.transform = self.passwordResetButton.transform.rotated(by: val)
        }) { (finished: Bool) -> Void in
            if(finished) {
                if(self.isAnimatingReset) {
                    self.spinWithOptions(options: .curveLinear)
                } else if (options != .curveEaseOut) {
                    self.spinWithOptions(options: .curveEaseOut)
                } else {
                    self.updateValues()
                }
            }
        }
    }
}
