//
//  AccountBasicInfoViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-28.
//

import UIKit

enum EditScreens: Int {
    case aboutMe
    case aboutHer
    
    func cellNames(mode: UserTypeMode) -> [String] {
        if mode == .normal {
            switch self {
            case .aboutMe:
                return ["SetupUserSelfCell", "SetupCareerCell", "SetupGenderPerfForCell", "SetupAssetsCell"]
            case .aboutHer:
                return ["SetupAboutPartnerCell", "PartnerDetailsCell"]
            }
        } else {
            switch self {
            case .aboutMe:
                return ["SetupCupidSelfCell", "SetupCareerCell"]
            case .aboutHer:
                fatalError()
            }
        }
    }
}

class EditBasicInfoViewController: BaseViewController {    
    var screen: EditScreens = .aboutMe
    
    private var mode: UserTypeMode!
    private var updateParams: UpdateUserParams!
    
    @IBOutlet weak private var tableView: UITableView!
    
    override func setup() {
        super.setup()
        
        mode = user.userType
        updateParams = UpdateUserParams(userInfo: user)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        if !validateCurrentStep() {
            return
        }
        
        FullScreenSpinner().show()
        userManager.updateProfile(params: updateParams) { [weak self] success in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            if success {
                self.backPressed(UIBarButtonItem())
            }
        }
    }
    
    private func validateCurrentStep() -> Bool {
        switch screen {
        case .aboutMe:
            // check for name, horoscope, year, height, ethnicity, religion, school, job title, gender, other gender, relationship, city, country
            if !Validator.validate(string: updateParams.firstName ?? "", validation: .isAProperName) {
                showErrorDialog(error: "Please enter a proper first name")
                return false
            }
            if updateParams.horoscope == nil {
                showErrorDialog(error: "Please input a horoscope")
                return false
            }
            if (Date().year() - (updateParams.birthYear ?? 0)) < 18 {
                showErrorDialog(error: "Please enter a proper birthday(18 years old and above)")
                return false
            }
            if user.userType == .normal, updateParams.height == nil {
                showErrorDialog(error: "Please input your height")
                return false
            }
            if user.userType == .normal, updateParams.bodyType == nil {
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
            if updateParams.gender == nil {
                showErrorDialog(error: "Please input your gender")
                return false
            }
            if user.userType == .normal, updateParams.dateGender == nil {
                showErrorDialog(error: "Please input your sexual orientation")
                return false
            }
            if user.userType == .normal, updateParams.lookingFor == nil {
                showErrorDialog(error: "Please input your desired relationship type")
                return false
            }
            if user.userType == .normal, updateParams.sibling == nil {
                showErrorDialog(error: "Please input your siblings information")
                return false
            }
            if user.userType == .normal, updateParams.child == nil {
                showErrorDialog(error: "Please input your child preference")
                return false
            }
        case .aboutHer:
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
                showErrorDialog(error: "Please input your desired partner's minimum income")
                return false
            }
        }
        
        return true
    }
}

extension EditBasicInfoViewController: SetupSelfCellDelegate, SetupCareerCellDelegate, SetupAssetsCellDelegate, SetupGenderPerfForCellDelegate, SetupUploadPhotosCellDelegate, PartnerDetailsCellDelegate {
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

extension EditBasicInfoViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screen.cellNames(mode: mode).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stepName = screen.cellNames(mode: mode)[indexPath.row]
        
        var tableCell: UITableViewCell!
        
        switch stepName {
        case "SetupUserSelfCell", "SetupCupidSelfCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? SetupSelfCell else {
                return SetupSelfCell()
            }
            cell.delegate = self
            cell.config(updateParams: updateParams, parentVC: self)
            tableCell = cell
        case "SetupCareerCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? SetupCareerCell else {
                return SetupCareerCell()
            }
            cell.config(updateParams: updateParams)
            cell.delegate = self
            tableCell = cell
        case "SetupGenderPerfForCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? SetupGenderPerfForCell else {
                return SetupGenderPerfForCell()
            }
            cell.config(updateParams: updateParams)
            cell.delegate = self
            tableCell = cell
        case "SetupAssetsCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? SetupAssetsCell else {
                return SetupAssetsCell()
            }
            cell.config(updateParams: updateParams)
            cell.delegate = self
            tableCell = cell
        case "PartnerDetailsCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? PartnerDetailsCell else {
                return PartnerDetailsCell()
            }
            cell.config(updateParams: updateParams)
            cell.delegate = self
            tableCell = cell
        default:
            tableCell = UITableViewCell()
        }
        
        return tableCell
    }
}
