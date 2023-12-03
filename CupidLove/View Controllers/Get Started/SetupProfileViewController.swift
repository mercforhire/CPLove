//
//  SetupProfileViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-14.
//

import UIKit
import SwiftUI

class SetupProfileViewController: BaseViewController {
    enum SetupProfileSteps: Int {
        case inviteCode
        case inputFields
        case inputFields2
        case uploadPhotos
        case aboutMe
        case count
        
        static func steps(mode: UserTypeMode) -> [SetupProfileSteps] {
            if mode == .normal {
                return [.inviteCode, .inputFields, .inputFields2, .uploadPhotos, .aboutMe]
            } else {
                return [.inputFields, .uploadPhotos, .aboutMe]
            }
        }
        
        func cellNames(mode: UserTypeMode, invitedBy: Bool) -> [String] {
            if mode == .normal {
                switch self {
                case .inviteCode:
                    return invitedBy ? ["SetupInvitedCell"] : ["SetupWelcomeCell"]
                case .inputFields:
                    return ["SetupUserSelfCell", "SetupCareerCell", "SetupAssetsCell"]
                case .inputFields2:
                    return ["SetupGenderPerfForCell", "PartnerDetailsCell" ]
                case .uploadPhotos:
                    return ["SetupUploadPhotosCell"]
                case .aboutMe:
                    return ["SetupAboutYouCell"]
                default:
                    fatalError()
                }
            } else {
                switch self {
                case .inputFields:
                    return ["SetupCupidSelfCell", "SetupCareerCell"]
                case .uploadPhotos:
                    return ["SetupUploadPhotosCell"]
                case .aboutMe:
                    return ["SetupAboutYouCell"]
                default:
                    fatalError()
                }
            }
        }
    }

    

    private var mode: UserTypeMode = .normal
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var rightButton: UIButton!
    
    private var stepNumber: Int = 0 {
        didSet {
            switch stepNumber {
            case (SetupProfileSteps.steps(mode: mode).count - 1):
                rightButton.setTitle("Start", for: .normal)
            default:
                rightButton.setTitle("Next", for: .normal)
            }
            progress.progress = Float(stepNumber) / Float(setupSteps.count)
            tableView.reloadData()
        }
    }
    private var setupSteps: [SetupProfileSteps] {
        return SetupProfileSteps.steps(mode: mode)
    }
    
    private var code: String?
    private var invitedBy: UserQuery? {
        didSet {
            tableView.reloadData()
            rightButton.isHidden = false
            
            updateParams.invitedBy = invitedBy?.identifier
        }
    }
    private var updateParams: UpdateUserParams = UpdateUserParams()
    
    override func setup() {
        super.setup()
        
        mode = user.userType
        
        switch mode {
        case .normal:
            progress.tintColor = themeManager.themeData!.pink.hexColor
        case .cupid:
            progress.tintColor = themeManager.themeData!.blue.hexColor
        case .admin:
            progress.tintColor = themeManager.themeData!.blue.hexColor
        }
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.viewControllers = [self]
        stepNumber = 0
        updateParams.notificationLevel = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func leftPressed(_ sender: UIButton) {
        if stepNumber == 0 {
            userManager.logout()
            return
        }
        stepNumber = stepNumber - 1
    }
    
    @IBAction func rightPressed(_ sender: UIButton) {
        if !validateCurrentStep() {
            return
        }
        
        if stepNumber == setupSteps.count - 1 {
            FullScreenSpinner().show()
            updateParams.isUserInfoComplete = true
            userManager.updateProfileRegistration(params: updateParams) { [weak self] success in
                guard let self = self else { return }
                FullScreenSpinner().hide()
                if success {
                    self.userManager.goToMain()
                }
            }
        } else {
            stepNumber = stepNumber + 1
            
            if setupSteps[stepNumber].cellNames(mode: mode, invitedBy: invitedBy != nil).count == 0 {
                rightPressed(sender)
            }
        }
    }
    
    @objc func submitInviteCode(_ sender: UIButton) {
        guard let code = code, !code.isEmpty else {
            showErrorDialog(error: "Invitation code invalid")
            return
        }
        
        FullScreenSpinner().show()
        
        api.getUserByInviteCode(inviteCode: code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if let user = response.data {
                    self.invitedBy = user
                } else {
                    showErrorDialog(code: response.code)
                }
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
            FullScreenSpinner().hide()
        }
    }
    
    @objc private func skipPressed(_ sender: UIButton) {
        rightPressed(sender)
    }
    
    @objc private func textFieldDidChange(_ textfield: UITextField) {
        // invitation code
        if textfield.tag == 123 {
            code = textfield.text
        }
    }
    
    private func validateCurrentStep() -> Bool {
        switch setupSteps[stepNumber] {
        case .inviteCode:
            break
        case .inputFields:
            switch mode {
            case .normal:
                // check for name, horoscope, year, height, ethnicity, religion, school, job title, gender, other gender, relationship, city, country
                if !Validator.validate(string: updateParams.firstName ?? "", validation: .isAProperName) {
                    showErrorDialog(error: "Please enter a proper first name")
                    return false
                }
                if updateParams.horoscope == nil {
                    showErrorDialog(error: "Please input a horoscope")
                    return false
                }
                if (Date().year() - (updateParams.birthYear ?? 0)) < 18, (updateParams.birthYear ?? 0) <= 1900 {
                    showErrorDialog(error: "Please enter a proper birthday(18 years old and above)")
                    return false
                }
                if updateParams.height == nil {
                    showErrorDialog(error: "Please input your height")
                    return false
                }
                if updateParams.bodyType == nil {
                    showErrorDialog(error: "Please input your body type")
                    return false
                }
                if updateParams.ethnicity == nil {
                    showErrorDialog(error: "Please input your ethnicity")
                    return false
                }
                if updateParams.religion == nil {
                    showErrorDialog(error: "Please input your religion(or lack of)")
                    return false
                }
                if updateParams.cityName?.isEmpty ?? true {
                    showErrorDialog(error: "Please input your city")
                    return false
                }
                if updateParams.school?.isEmpty ?? true {
                    showErrorDialog(error: "Please input your school")
                    return false
                }
                if updateParams.jobTitle?.isEmpty ?? true {
                    showErrorDialog(error: "Please input your job title")
                    return false
                }
                if updateParams.minIncome == nil || updateParams.maxIncome == nil {
                    showErrorDialog(error: "Please input your income range")
                    return false
                }
                if updateParams.sibling == nil {
                    showErrorDialog(error: "Please input your siblings information")
                    return false
                }
                if updateParams.child == nil {
                    showErrorDialog(error: "Please input your child preference")
                    return false
                }
            case .cupid:
                // check for name, horoscope, year, ethnicity, religion, school, job title, income, city, country
                if !Validator.validate(string: updateParams.firstName ?? "", validation: .isAProperName) {
                    showErrorDialog(error: "Please enter a proper first name")
                    return false
                }
                if updateParams.horoscope == nil {
                    showErrorDialog(error: "Please input a horoscope")
                    return false
                }
                if (Date().year() - (updateParams.birthYear ?? 0)) < 18, (updateParams.birthYear ?? 0) <= 1900 {
                    showErrorDialog(error: "Please enter a proper birthday(18 years old and above)")
                    return false
                }
                if updateParams.ethnicity == nil {
                    showErrorDialog(error: "Please input your ethnicity")
                    return false
                }
                if updateParams.religion == nil {
                    showErrorDialog(error: "Please input your religion(or lack of)")
                    return false
                }
                if updateParams.school?.isEmpty ?? true {
                    showErrorDialog(error: "Please input your school")
                    return false
                }
                if updateParams.jobTitle?.isEmpty ?? true {
                    showErrorDialog(error: "Please input your job title")
                    return false
                }
                if updateParams.cityName?.isEmpty ?? true {
                    showErrorDialog(error: "Please input your city")
                    return false
                }
            case .admin:
                return true
            }
        case .inputFields2:
            switch mode {
            case .normal:
                if updateParams.gender == nil {
                    showErrorDialog(error: "Please input your gender")
                    return false
                }
                if updateParams.dateGender == nil {
                    showErrorDialog(error: "Please input your sexual orientation")
                    return false
                }
                if updateParams.lookingFor == nil {
                    showErrorDialog(error: "Please input your desired relationship type")
                    return false
                }
                if updateParams.desiredEthnicity == nil {
                    showErrorDialog(error: "Please input your desired ethnicity(s)")
                    return false
                }
                if updateParams.desiredMinAge == nil || (updateParams.desiredMinAge ?? 0) < 18 {
                    showErrorDialog(error: "Please input your desired partner min age(18+)")
                    return false
                }
                if updateParams.desiredMaxAge == nil || (updateParams.desiredMaxAge ?? 0) < 18 || (updateParams.desiredMinAge ?? 0) > (updateParams.desiredMaxAge ?? 0) {
                    showErrorDialog(error: "Please input a proper your desired partner max age(18+)")
                    return false
                }
                if updateParams.desiredReligion == nil {
                    showErrorDialog(error: "Please input your desired partner's religion")
                    return false
                }
                if updateParams.desiredMinIncome == nil {
                    showErrorDialog(error: "Please input your desired partner's income")
                    return false
                }
            case .cupid:
                return true
            case .admin:
                return true
            }
        case .uploadPhotos:
            // check for at least 1 photo
            if updateParams.personalPhotos?.isEmpty ?? true {
                showErrorDialog(error: "Please add at least 1 photo")
                return false
            }
        case .aboutMe:
            // check for about me
            if updateParams.aboutMe?.isEmpty ?? true {
                showErrorDialog(error: "Please fill out about me")
                return false
            }
        default:
            break
        }
        
        return true
    }
}

extension SetupProfileViewController: SetupSelfCellDelegate, SetupCareerCellDelegate, SetupAssetsCellDelegate, SetupGenderPerfForCellDelegate, SetupUploadPhotosCellDelegate, SetupAboutYouCellDelegate, PartnerDetailsCellDelegate {
    func imagesChanged(images: [UIImage]) {
        
    }
    
    func bodyTypeChanged(bodyType: String) {
        updateParams.bodyType = bodyType
    }
    
    func desiredEthnicitiesChanged(ethnicities: [Ethnicities]) {
        updateParams.desiredEthnicity = ethnicities
    }
    
    func desiredCityChanged(city: String) {
        updateParams.desiredCityName = city
    }
    
    func desiredMinAgeChanged(min: Int) {
        updateParams.desiredMinAge = min
    }
    
    func desiredMaxAgeChanged(max: Int) {
        updateParams.desiredMaxAge = max
    }
    
    func desiredReligionChanged(religion: Religions) {
        updateParams.desiredReligion = [religion]
    }
    
    func desiredIncomeChanged(min: Incomes) {
        updateParams.desiredMinIncome = min
    }
    
    func desiredPersonalities(personalities: [Personality]) {
        updateParams.desiredPersonality = personalities
    }
    
    func locationChanged(city: String, country: String, coordinates: [Double]) {
        updateParams.cityName = city
        updateParams.countryName = country
        updateParams.location = GPSLocation(coordinates: coordinates)
    }
    
    func nameChanged(name: String) {
        updateParams.firstName = name
    }
    
    func yearChanged(year: Int) {
        updateParams.birthYear = year
    }
    
    func profileImagesChanged(profileImages: [PhotoResponse]) {
        updateParams.personalPhotos = profileImages
    }
    
    func aboutMeChanged(text: String) {
        updateParams.aboutMe = text
    }
    
    func assetsChanged(assets: [Assets]) {
        updateParams.asset = assets
    }
    
    func siblingsChanged(siblings: Siblings) {
        updateParams.sibling = siblings
    }
    
    func childPreferenceChanged(preference: ChildPreference) {
        updateParams.child = preference
    }
    
    func genderChanged(gender: GenderChoice) {
        updateParams.gender = gender
    }
    
    func dateGenderChanged(dateGender: GenderChoice) {
        updateParams.dateGender = dateGender
    }
    
    func lookingForChanged(lookingFor: RelationshipTypes) {
        updateParams.lookingFor = lookingFor
    }
    
    func schoolChanged(school: String) {
        updateParams.school = school
    }
    
    func jobChanged(job: String) {
        updateParams.jobTitle = job
    }
    
    func incomeChanged(incomeRange: [Incomes]) {
        updateParams.minIncome = incomeRange.first
        updateParams.maxIncome = incomeRange.last
    }
    
    func horoscopeChanged(horoscope: Horoscopes) {
        updateParams.horoscope = horoscope
    }
    
    func heightChanged(height: HeightSelections) {
        updateParams.height = height
    }
    
    func ethnicityChanged(ethnicity: Ethnicities) {
        updateParams.ethnicity = ethnicity
    }
    
    func religionChanged(religion: Religions) {
        updateParams.religion = religion
    }
}

extension SetupProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setupSteps[stepNumber].cellNames(mode: mode, invitedBy: invitedBy != nil).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellName = setupSteps[stepNumber].cellNames(mode: mode, invitedBy: invitedBy != nil)[indexPath.row]
        
        var tableCell: UITableViewCell!
        
        switch cellName {
        case "SetupWelcomeCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupWelcomeCell else {
                return SetupWelcomeCell()
            }
            cell.titleLabel.textColor = mode == .normal ? themeManager.themeData!.pink.hexColor : themeManager.themeData!.blue.hexColor
            cell.codeField.tag = 123
            cell.codeField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            cell.submitButton.addTarget(self, action: #selector(submitInviteCode), for: .touchUpInside)
            cell.skipButton.addTarget(self, action: #selector(skipPressed), for: .touchUpInside)
            tableCell = cell
        case "SetupInvitedCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupInvitedCell,
                    let invitedBy = invitedBy else {
                return SetupInvitedCell()
            }
            cell.config(user: invitedBy)
            tableCell = cell
        case "SetupUserSelfCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupSelfCell else {
                return SetupSelfCell()
            }
            cell.config(updateParams: updateParams, parentVC: self)
            cell.delegate = self
            tableCell = cell
        case "SetupCupidSelfCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupSelfCell else {
                return SetupSelfCell()
            }
            cell.config(updateParams: updateParams, parentVC: self)
            cell.delegate = self
            tableCell = cell
        case "SetupCareerCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupCareerCell else {
                return SetupCareerCell()
            }
            cell.config(updateParams: updateParams)
            cell.delegate = self
            tableCell = cell
        case "SetupGenderPerfForCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupGenderPerfForCell else {
                return SetupGenderPerfForCell()
            }
            cell.config(updateParams: updateParams)
            cell.delegate = self
            tableCell = cell
        case "PartnerDetailsCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? PartnerDetailsCell else {
                return PartnerDetailsCell()
            }
            cell.parentVC = self
            cell.config(updateParams: updateParams)
            cell.delegate = self
            tableCell = cell
        case "SetupAssetsCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupAssetsCell else {
                return SetupAssetsCell()
            }
            cell.config(updateParams: updateParams)
            cell.delegate = self
            tableCell = cell
        case "SetupUploadPhotosCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupUploadPhotosCell else {
                return SetupUploadPhotosCell()
            }
            cell.parentVC = self
            cell.userManager = userManager
            cell.titleLabel?.textColor = mode == .normal ? themeManager.themeData!.pink.hexColor : themeManager.themeData!.blue.hexColor
            cell.config(updateParams: updateParams, userManager: userManager)
            cell.delegate = self
            tableCell = cell
        case "SetupAboutYouCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupAboutYouCell else {
                return SetupAboutYouCell()
            }
            cell.titleLabel.textColor = mode == .normal ? themeManager.themeData!.pink.hexColor : themeManager.themeData!.blue.hexColor
            cell.config(updateParams: updateParams)
            cell.delegate = self
            tableCell = cell
        default:
            tableCell = UITableViewCell()
        }
        
        return tableCell
    }
}
