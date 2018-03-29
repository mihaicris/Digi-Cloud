//
//  ShareLinkViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class ShareLinkViewController: UIViewController {

    // MARK: - Private types

    private enum Sections {
        case location
        case link
        case password
        case validity
    }

    // MARK: - Internal Properties

    var onFinish: ((Bool) -> Void)?

    // MARK: - Internal Properties

    private let location: Location
    private let linkType: LinkType
    private var sections: [Sections] = []
    private var originalLinkHash: String!
    private var isSaving: Bool = false
    private var isAnimatingReset: Bool = false
    private var errorMessageVerticalConstraint: NSLayoutConstraint!
    private var rightTextFieldConstraintDefault: NSLayoutConstraint!
    private var rightTextFieldConstraintInEditMode: NSLayoutConstraint!

    private var link: Link! {
        didSet {
            if !isAnimatingReset {
                updateValues()
            }
        }
    }

    private lazy var tableView: UITableView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        let tableView = UITableView(frame: frame, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private var spinner: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    let baseLinkLabel: UILabelWithPadding = {
        let label = UILabelWithPadding(paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private lazy var hashTextField: URLHashTextField = {
        let textField = URLHashTextField()
        textField.delegate = self
        return textField
    }()

    private lazy var saveHashButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSaveShortURLButtonTouched), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private let enablePasswordSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.isOn = true
        uiSwitch.addTarget(self, action: #selector(handleEnablePasswordSwitchValueChanged(_:)), for: .valueChanged)
        return uiSwitch
    }()

    private let uploadNotificationSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.isOn = false
        uiSwitch.addTarget(self, action: #selector(handleEmailNotificationSwitchValueChanged(_:)), for: .valueChanged)
        return uiSwitch
    }()

    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private lazy var passwordResetButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        button.setImage(#imageLiteral(resourceName: "refresh_icon").withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleResetPasswordButtonTouched), for: .touchUpInside)
        return button
    }()

    private let validityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private let changeValidityButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Change", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleChangeValidityButtonTouched), for: .touchUpInside)
        return button
    }()

    private let counterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.fontHelveticaNeue(size: 14)
        label.textColor = UIColor.white
        return label
    }()

    private let saveCustomDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSaveCustomDateButtonTouched), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private let validityDateAndTimePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.locale = .current
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 30
        datePicker.addTarget(self, action: #selector(handleDatePickerValueChanged(_:)), for: .valueChanged)
        datePicker.isHidden = true
        return datePicker
    }()

    private lazy var validitySegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [
            NSLocalizedString("1 hour", comment: ""),
            NSLocalizedString("1 day", comment: ""),
            NSLocalizedString("1 Month", comment: ""),
            NSLocalizedString("Forever", comment: ""),
            NSLocalizedString("Custom", comment: "")
        ])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)], for: .normal)
        segmentedControl.addTarget(self, action: #selector(handleValiditySegmentedControlValueChanged(_:)), for: .valueChanged)
        segmentedControl.isHidden = true
        return segmentedControl
    }()

    private lazy var waitingView: UIView = {
        let view = UIView()
        view.isHidden = false
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false

        let spinner: UIActivityIndicatorView = {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.hidesWhenStopped = true
            activityIndicator.tag = 55
            activityIndicator.startAnimating()
            return activityIndicator
        }()

        let okButton: UIButton = {
            let button = UIButton(type: UIButtonType.system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(NSLocalizedString("OK", comment: ""), for: UIControlState.normal)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 10
            button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 40, bottom: 2, right: 40)
            button.sizeToFit()
            button.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.9, alpha: 1)
            button.tag = 11
            button.isHidden = true
            button.addTarget(self, action: #selector(handleOKButtonTouched), for: .touchUpInside)
            return button
        }()

        let label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .gray
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.tag = 99
            label.numberOfLines = 0
            return label
        }()

        view.addSubview(spinner)
        view.addSubview(label)
        view.addSubview(okButton)

        self.errorMessageVerticalConstraint = label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.errorMessageVerticalConstraint,
            okButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            okButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40)
        ])

        return view
    }()

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYY・HH:mm"
        return formatter
    }()

    init(location: Location, linkType: LinkType, onFinish: @escaping (Bool) -> Void) {
        self.location = location
        self.linkType = linkType
        self.onFinish = onFinish
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - View Controller Methods

extension ShareLinkViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationItems()
        setupToolBarItems()
        addViewTapGestureRecognizer()
        configureWaitingView(type: .started, message: NSLocalizedString("Preparing Link", comment: ""))
        requestLink()
    }

}

// MARK: - UITableViewDataSource Conformance

extension ShareLinkViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .location:
            return 1
        case .link:
            return linkType == .upload ? 2 : 1
        case .password:
            return 1
        case .validity:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none

        switch sections[indexPath.section] {
        case .location:

            let mountNameLabel: UILabelWithPadding = {
                let label = UILabelWithPadding(paddingTop: 1, paddingLeft: 5, paddingBottom: 2, paddingRight: 5)
                label.font = UIFont.fontHelveticaNeue(size: 12)
                label.adjustsFontSizeToFitWidth = true
                label.textColor = .darkGray
                label.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                label.text = location.mount.name
                label.layer.cornerRadius = 4
                label.clipsToBounds = true
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }()

            let locationPathLabel: UILabel = {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textColor = .darkGray
                label.text = location.path.hasSuffix("/") ? String(location.path.dropLast()) : location.path
                label.numberOfLines = 2
                label.font = UIFont.fontHelveticaNeue(size: 12)
                label.lineBreakMode = .byTruncatingMiddle
                return label
            }()

            cell.contentView.addSubview(mountNameLabel)
            cell.contentView.addSubview(locationPathLabel)

            NSLayoutConstraint.activate([
                locationPathLabel.leftAnchor.constraint(equalTo: mountNameLabel.rightAnchor, constant: 2),
                locationPathLabel.rightAnchor.constraint(lessThanOrEqualTo: cell.contentView.layoutMarginsGuide.rightAnchor),
                locationPathLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),

                mountNameLabel.leftAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leftAnchor),
                mountNameLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)])

        case .link:

            if indexPath.row == 0 {
                cell.contentView.addSubview(baseLinkLabel)
                cell.contentView.addSubview(hashTextField)
                cell.contentView.addSubview(saveHashButton)

                rightTextFieldConstraintDefault = hashTextField.rightAnchor.constraint(equalTo: cell.layoutMarginsGuide.rightAnchor)
                rightTextFieldConstraintInEditMode = hashTextField.rightAnchor.constraint(equalTo: saveHashButton.leftAnchor, constant: -8)

                NSLayoutConstraint.activate([
                    baseLinkLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    baseLinkLabel.leftAnchor.constraint(equalTo: cell.layoutMarginsGuide.leftAnchor),
                    baseLinkLabel.heightAnchor.constraint(equalToConstant: 30),

                    saveHashButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    saveHashButton.rightAnchor.constraint(equalTo: cell.layoutMarginsGuide.rightAnchor),

                    hashTextField.leftAnchor.constraint(lessThanOrEqualTo: baseLinkLabel.rightAnchor, constant: 2),
                    rightTextFieldConstraintDefault,
                    hashTextField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    hashTextField.heightAnchor.constraint(equalToConstant: 30)])

                hashTextField.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)

            } else if linkType == .upload {
                let label: UILabel = {
                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.text = NSLocalizedString("Email on receiving files", comment: "")
                    return label
                }()

                cell.contentView.addSubview(label)
                cell.contentView.addSubview(uploadNotificationSwitch)

                NSLayoutConstraint.activate([
                    label.leftAnchor.constraint(equalTo: cell.layoutMarginsGuide.leftAnchor),
                    label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    uploadNotificationSwitch.rightAnchor.constraint(equalTo: cell.layoutMarginsGuide.rightAnchor),
                    uploadNotificationSwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)])
            }
        case .password:

            cell.contentView.addSubview(passwordLabel)
            cell.contentView.addSubview(passwordResetButton)
            cell.contentView.addSubview(enablePasswordSwitch)

            NSLayoutConstraint.activate([
                passwordLabel.leftAnchor.constraint(equalTo: cell.layoutMarginsGuide.leftAnchor),
                passwordLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                passwordResetButton.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor, constant: 90),
                passwordResetButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                enablePasswordSwitch.rightAnchor.constraint(equalTo: cell.layoutMarginsGuide.rightAnchor),
                enablePasswordSwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)])

        case .validity:

            cell.contentView.addSubview(validityLabel)
            cell.contentView.addSubview(changeValidityButton)
            cell.contentView.addSubview(validitySegmentedControl)
            cell.contentView.addSubview(validityDateAndTimePicker)
            cell.contentView.addSubview(saveCustomDateButton)
            cell.contentView.addSubview(spinner)

            NSLayoutConstraint.activate([
                validityLabel.leftAnchor.constraint(equalTo: cell.layoutMarginsGuide.leftAnchor),
                validityLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                changeValidityButton.rightAnchor.constraint(equalTo: cell.layoutMarginsGuide.rightAnchor),
                changeValidityButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                validitySegmentedControl.leftAnchor.constraint(equalTo: cell.layoutMarginsGuide.leftAnchor),
                validitySegmentedControl.rightAnchor.constraint(equalTo: cell.layoutMarginsGuide.rightAnchor),
                validitySegmentedControl.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                spinner.rightAnchor.constraint(equalTo: cell.layoutMarginsGuide.rightAnchor),
                spinner.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                validityDateAndTimePicker.leftAnchor.constraint(equalTo: cell.layoutMarginsGuide.leftAnchor),
                validityDateAndTimePicker.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                validityDateAndTimePicker.heightAnchor.constraint(equalTo: cell.contentView.heightAnchor),
                saveCustomDateButton.rightAnchor.constraint(equalTo: cell.layoutMarginsGuide.rightAnchor),
                saveCustomDateButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let headerTitle: String

        switch sections[section] {
        case .location:
            headerTitle = NSLocalizedString("LOCATION", comment: "")
        case .link:
            headerTitle = NSLocalizedString("LINK", comment: "")
        case .password:
            headerTitle = NSLocalizedString("PASSWORD", comment: "")
        case .validity:
            headerTitle = NSLocalizedString("VALIDITY", comment: "")
        }
        return headerTitle
    }

}

// MARK: - UITableViewDelegate Conformance

extension ShareLinkViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sections[indexPath.section] == .validity && validityDateAndTimePicker.isHidden == false {
            return 150
        } else {
            return AppSettings.textFieldRowHeight
        }
    }

}

// MARK: - UITextFieldDelegate Conformance

extension ShareLinkViewController: UITextFieldDelegate {

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
        setTextFieldConstraintInEditMode(active: false)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if !isSaving {
            hashTextField.text = originalLinkHash
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if saveHashButton.isHidden == false {
            handleSaveShortURLButtonTouched()
            return true
        } else {
            return false
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Disable Save hash button if necessary
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let newHash = textFieldText.replacingCharacters(in: range, with: string)

        if newHash.count == 0 || newHash == originalLinkHash || hasInvalidCharacters(name: newHash) {
            saveHashButton.isHidden = true
            setTextFieldConstraintInEditMode(active: false)
        } else {
            saveHashButton.isHidden = false
            setTextFieldConstraintInEditMode(active: true)
        }
        return true
    }

}

// MARK: - Target Actions Methods

private extension ShareLinkViewController {

    @objc func handleShareButtonTouched() {
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

    @objc func handleSaveShortURLButtonTouched() {
        isSaving = true
        guard let hash = hashTextField.text else {
            print("No hash")
            return
        }
        DigiClient.shared.setLinkCustomShortUrl(mount: location.mount, linkId: link.identifier, type: linkType, hash: hash) { result, error in
            guard error == nil else {
                if let error = error as? NetworkingError {
                    if case NetworkingError.wrongStatus(_) = error {
                        let title = NSLocalizedString("Error", comment: "")
                        let message = NSLocalizedString("Sorry, this short URL is not available.", comment: "")
                        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "Gata", style: .default, handler: { _ in self.isSaving = false })
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    print(error!.localizedDescription)
                }
                return
            }
            guard result != nil else {
                print("No valid link")
                return
            }
            self.isSaving = false
            self.originalLinkHash = hash
            self.link = result!
        }
    }

    @objc func handleResetPasswordButtonTouched() {
        resetAllFields()
        startSpinning()
        DigiClient.shared.setOrResetLinkPassword(mount: location.mount, linkId: link.identifier, type: linkType, completion: { result, error in
            guard error == nil, result != nil else {
                print(error!.localizedDescription)
                return
            }
            self.link = result!
            self.stopSpinning()
        })
    }

    @objc func handleDeleteButtonTouched() {
        configureWaitingView(type: .started, message: NSLocalizedString("Deleting Link", comment: ""))
        DigiClient.shared.deleteLink(mount: location.mount, linkId: link.identifier, type: linkType) { error in
            guard error == nil else {
                self.configureWaitingView(type: .stopped, message: NSLocalizedString("There was an error communicating with the network.", comment: ""))
                return
            }
            self.dismiss(animated: true) {
                self.onFinish?(false)
            }
        }
    }

    @objc func handleEnablePasswordSwitchValueChanged(_ sender: UISwitch) {
        resetAllFields()
        startSpinning()
        if sender.isOn {
            handleResetPasswordButtonTouched()
        } else {
            DigiClient.shared.removeLinkPassword(mount: location.mount, linkId: link.identifier, type: linkType) { result, error in
                self.stopSpinning()
                guard error == nil, result != nil else {
                    self.stopSpinning()
                    sender.setOn(true, animated: true)
                    print(error!.localizedDescription)
                    return
                }
                self.link = result!
            }
        }
    }

    @objc func handleTapGestureRecognized() {
        hashTextField.text = originalLinkHash
        hashTextField.resignFirstResponder()
    }

    @objc func handleDoneButtonTouched() {
        dismiss(animated: true) {
            self.onFinish?(false)
        }
    }

    @objc func handleOKButtonTouched(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc func handleChangeValidityButtonTouched() {
        resetAllFields()
        validityLabel.isHidden = true
        changeValidityButton.isHidden = true
        validitySegmentedControl.isHidden = false
        validitySegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }

    @objc func handleValiditySegmentedControlValueChanged(_ sender: UISegmentedControl) {
        var validityDate: TimeInterval?
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
            tableView.selectRow(at: IndexPath(row: 0, section: 3), animated: true, scrollPosition: .bottom)
            return
        default:
            return
        }
        if let calendarComponent = calendarComponent,
            let date = Calendar.current.date(byAdding: calendarComponent, value: 1, to: Date()) {
            validityDate = date.timeIntervalSince1970
        }
        saveCustomValidationDate(validTo: validityDate)
    }

    @objc func handleDatePickerValueChanged(_ sender: UIDatePicker) {
        let customDate = sender.date
        let minimumDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        if customDate < minimumDate {
            saveCustomDateButton.isHidden = true
        } else {
            saveCustomDateButton.isHidden = false
        }
    }

    @objc func handleSaveCustomDateButtonTouched() {
        let customDate = validityDateAndTimePicker.date
        let validTo = customDate.timeIntervalSince1970
        saveCustomDateButton.isHidden = true
        saveCustomValidationDate(validTo: validTo)
    }

    @objc func handleEmailNotificationSwitchValueChanged(_ sender: UISwitch) {
        resetAllFields()
        DigiClient.shared.setReceiverAlert(isOn: sender.isOn, mount: location.mount, linkId: link.identifier) { result, error in
            guard error == nil, result != nil else {
                sender.setOn(!sender.isOn, animated: true)
                print(error!.localizedDescription)
                return
            }
            self.link = result!
        }
    }

}

// MARK: - Private Methods

private extension ShareLinkViewController {

    func setTextFieldConstraintInEditMode(active: Bool) {
        rightTextFieldConstraintDefault.isActive = false
        rightTextFieldConstraintInEditMode.isActive = false
        rightTextFieldConstraintDefault.isActive = !active
        rightTextFieldConstraintInEditMode.isActive = active
        self.hashTextField.superview!.layoutIfNeeded()
    }

    func setupViews() {
        let headerView: UIImageView = {
            let imageView = UIImageView(frame: CGRect.zero)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = linkType == .download ? #imageLiteral(resourceName: "share_download_link_background") : #imageLiteral(resourceName: "share_upload_link_background")
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()

        tableView.alwaysBounceVertical = false

        view.addSubview(headerView)
        headerView.addSubview(counterLabel)

        view.addSubview(tableView)
        view.addSubview(waitingView)

        NSLayoutConstraint.activate([

            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor),

            counterLabel.rightAnchor.constraint(equalTo: headerView.layoutMarginsGuide.rightAnchor),
            counterLabel.bottomAnchor.constraint(equalTo: headerView.layoutMarginsGuide.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),

            waitingView.topAnchor.constraint(equalTo: view.topAnchor),
            waitingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            waitingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            waitingView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])

        sections = [.location, .link, .password, .validity]
    }

    func setupNavigationItems() {
        if linkType == .download {
            title = NSLocalizedString("Send Link", comment: "")
        } else {
            title = NSLocalizedString("Receive Files", comment: "")
        }

        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(handleDoneButtonTouched))
        navigationItem.setRightBarButton(doneButton, animated: false)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .done, target: nil, action: nil)
    }

    func setupToolBarItems() {
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        let deleteButton: UIBarButtonItem = {
            let buttonView = UIButton(type: UIButtonType.system)
            buttonView.setTitle(NSLocalizedString("Delete Link", comment: ""), for: .normal)
            buttonView.addTarget(self, action: #selector(handleDeleteButtonTouched), for: .touchUpInside)
            buttonView.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .disabled)
            buttonView.setTitleColor(.red, for: .normal)
            buttonView.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            buttonView.sizeToFit()
            let button = UIBarButtonItem(customView: buttonView)
            return button
        }()

        let shareButton: UIBarButtonItem = {
            let buttonView = UIButton(type: UIButtonType.system)
            buttonView.setTitle(NSLocalizedString("Share", comment: ""), for: .normal)
            buttonView.addTarget(self, action: #selector(handleShareButtonTouched), for: .touchUpInside)
            buttonView.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .disabled)
            buttonView.setTitleColor(.red, for: .normal)
            buttonView.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            buttonView.sizeToFit()
            let button = UIBarButtonItem(customView: buttonView)
            return button
        }()

        setToolbarItems([deleteButton, flexibleButton, shareButton], animated: false)
    }

    func addViewTapGestureRecognizer() {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognized))
        view.addGestureRecognizer(tgr)
    }

    func configureWaitingView(type: WaitingType, message: String = "") {
        switch type {
        case .hidden:
            waitingView.isHidden = true
            navigationController?.setToolbarHidden(false, animated: false)
        case .started, .stopped:
            waitingView.isHidden = false
            navigationController?.setToolbarHidden(true, animated: false)
            if let activityIndicator = waitingView.viewWithTag(55) as? UIActivityIndicatorView,
                let button = waitingView.viewWithTag(11) as? UIButton {
                if type == .started {
                    activityIndicator.startAnimating()
                    button.isHidden = true
                    errorMessageVerticalConstraint.constant = 40
                } else {
                    activityIndicator.stopAnimating()
                    button.isHidden = false
                    errorMessageVerticalConstraint.constant = 0
                }
            }

            if let label = waitingView.viewWithTag(99) as? UILabel {
                label.text = message
            }
        }
    }

    func requestLink() {
        DigiClient.shared.getLink(for: location, type: linkType) { result, error in
            guard error == nil, result != nil else {
                let message = NSLocalizedString("There was an error, please try again later.", comment: "")
                self.configureWaitingView(type: .stopped, message: message)
                return
            }
            self.link = result!
            self.configureWaitingView(type: .hidden)
        }
    }

    func hasInvalidCharacters(name: String) -> Bool {
        let charset = CharacterSet.init(charactersIn: name)
        return !charset.isDisjoint(with: CharacterSet.alphanumerics.inverted)
    }

    func setDateAndTimePickerViewVisible(_ visible: Bool) {
        if visible {
            validityDateAndTimePicker.minimumDate = Date()
            validityDateAndTimePicker.isHidden = false
        } else {
            validityDateAndTimePicker.isHidden = true
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func saveCustomValidationDate(validTo: TimeInterval?) {
        spinner.startAnimating()
        DigiClient.shared.setLinkCustomValidity(mount: location.mount, linkId: link.identifier, type: linkType, validTo: validTo) { result, error in
            self.spinner.stopAnimating()
            guard error == nil, result != nil else {
                print(error!.localizedDescription)
                return
            }
            self.resetAllFields()
            self.link = result!
        }
    }

    func resetAllFields() {
        hashTextField.resignFirstResponder()
        setDateAndTimePickerViewVisible(false)
        validityLabel.isHidden = false
        changeValidityButton.isHidden = false
        validitySegmentedControl.isHidden = true
    }

    func updateValues() {
        originalLinkHash = link.hash
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

        var counterString: String

        if linkType == .download {
            if link.counter == 1 {
                counterString = NSLocalizedString("Seen %d time", comment: "")
            } else {
                counterString = NSLocalizedString("Seen %d times", comment: "")
            }

        } else {
            if link.counter == 1 {
                counterString = NSLocalizedString("Uploaded %d time", comment: "")
            } else {
                counterString = NSLocalizedString("Uploaded %d times", comment: "")
            }
        }

        counterLabel.text = String(format: counterString, link.counter)
        waitingView.isHidden = true
    }

    func startSpinning() {
        if !isAnimatingReset {
            isAnimatingReset = true
            spinWithOptions(options: .curveEaseIn)
        }
    }

    func stopSpinning() {
        isAnimatingReset = false
    }

    func spinWithOptions(options: UIViewAnimationOptions) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: options,
            animations: { () -> Void in
                let val = CGFloat(Double.pi)
                self.passwordResetButton.transform = self.passwordResetButton.transform.rotated(by: val)
        },
            completion: { (finished: Bool) -> Void in
                if finished {
                    if self.isAnimatingReset {
                        self.spinWithOptions(options: .curveLinear)
                    } else if options != .curveEaseOut {
                        self.spinWithOptions(options: .curveEaseOut)
                    } else {
                        self.updateValues()
                    }
                }
        })
    }

}
