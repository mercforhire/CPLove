//
//  FilterViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-27.
//

import UIKit
import TTRangeSlider
import M13Checkbox

class IncomeNumberFormatter: NumberFormatter {
    override func string(from number: NSNumber) -> String? {
        let mileStone = Incomes.fromInt(int: number.intValue)
        return mileStone.title()
    }
}

protocol FilterViewControllerDelegate : class {
    func searchParamGenerated(searchParams: UserQueryParams, userType: UserTypeMode)
}

class FilterViewController: BaseViewController {
    var mode: UserTypeMode = .normal
    var searchParams: UserQueryParams!
    
    weak var delegate: FilterViewControllerDelegate?
    
    @IBOutlet var genderButtons: [ThemeRoundedWhiteBorderedButton]!
    
    @IBOutlet weak var ageContainer: UIView!
    @IBOutlet weak var ageSlider: TTRangeSlider!
    
    @IBOutlet weak var incomeContainer: UIView!
    @IBOutlet weak var incomeSlider: TTRangeSlider!
    
    @IBOutlet weak var sortByIncomeContainer: UIView!
    @IBOutlet weak var sortByIncomeCheckbox: M13Checkbox!
    
    @IBOutlet weak var datingSortContainer: UIView!
    @IBOutlet var datingSortButtons: [ThemeRoundedWhiteBorderedButton]!
    
    @IBOutlet weak var cupidSortContainer: UIView!
    @IBOutlet var cupidSortButtons: [ThemeRoundedWhiteBorderedButton]!
    
    @IBOutlet weak var locationButton: UIButton!
    
    override func setup() {
        super.setup()

        switch mode {
        case .normal:
            datingSortContainer.isHidden = false
            cupidSortContainer.isHidden = true
        case .cupid:
            incomeContainer.isHidden = true
            ageContainer.isHidden = true
            datingSortContainer.isHidden = true
            cupidSortContainer.isHidden = false
            sortByIncomeContainer.isHidden = true
        default:
            break
        }
        
        let formatter = IncomeNumberFormatter()
        incomeSlider.numberFormatterOverride = formatter
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
        ageSlider.minLabelColour = themeManager.themeData?.textLabel.hexColor
        ageSlider.maxLabelColour = themeManager.themeData?.textLabel.hexColor
        incomeSlider.minLabelColour = themeManager.themeData?.textLabel.hexColor
        incomeSlider.maxLabelColour = themeManager.themeData?.textLabel.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshScreen()
    }
    
    override func backPressed(_ sender: UIBarButtonItem) {
        super.backPressed(sender)
        
        delegate?.searchParamGenerated(searchParams: searchParams, userType: mode)
    }
    
    private func refreshScreen() {
        for button in genderButtons {
            if searchParams.gender?.rawValue == button.tag {
                button.highlightButton(back: mode.themeColor(),
                                       text: .white)
            } else {
                button.unhighlightButton(back: ThemeManager.shared.themeData!.whiteBackground.hexColor,
                                         text: ThemeManager.shared.themeData!.textLabel.hexColor)
            }
        }
        
        if let minAge = searchParams.minAge, let maxAge = searchParams.maxAge {
            ageSlider.selectedMinimum = Float(minAge)
            ageSlider.selectedMaximum = Float(maxAge)
        } else {
            ageSlider.selectedMinimum = 18.0
            ageSlider.selectedMaximum = 70.0
        }
        
        if let minIncome = searchParams.minIncome, let maxIncome = searchParams.maxIncome {
            incomeSlider.selectedMinimum = Float(minIncome.rawValue)
            incomeSlider.selectedMaximum = Float(maxIncome.rawValue)
        } else {
            incomeSlider.selectedMinimum = 0
            incomeSlider.selectedMaximum = Float(Incomes.incomeInfinite.rawValue)
        }
        
        sortByIncomeCheckbox.checkState = (searchParams.vipIncomeSort == true) ? .checked : .unchecked
        
        for button in datingSortButtons {
            if searchParams.daterSort?.rawValue == button.tag {
                button.highlightButton(back: mode.themeColor(),
                                       text: .white)
            } else {
                button.unhighlightButton(back: ThemeManager.shared.themeData!.whiteBackground.hexColor,
                                         text: ThemeManager.shared.themeData!.textLabel.hexColor)
            }
        }
        
        for button in cupidSortButtons {
            if searchParams.matchmakerSort?.rawValue == button.tag {
                button.highlightButton(back: mode.themeColor(), text: .white)
            } else {
                button.unhighlightButton(back: ThemeManager.shared.themeData!.whiteBackground.hexColor,
                                         text: ThemeManager.shared.themeData!.textLabel.hexColor)
            }
        }
        
        locationButton.setTitle(searchParams.cityName ?? "Canada", for: .normal)
    }
    
    @IBAction func genderButtonPressed(_ sender: UIButton) {
        guard let clickedGender: GenderChoice = GenderChoice(rawValue: sender.tag) else { return }
        
        if searchParams.gender == clickedGender {
            searchParams.gender = nil
        } else {
            searchParams.gender = clickedGender
        }
        refreshScreen()
    }
    
    @IBAction func ageChanged(_ sender: TTRangeSlider) {
        searchParams.minAge = Int(sender.selectedMinimum)
        searchParams.maxAge = Int(sender.selectedMaximum)
    }
    
    @IBAction func incomeChanged(_ sender: TTRangeSlider) {
        searchParams.minIncome = Incomes(rawValue: Int(sender.selectedMinimum))
        searchParams.maxIncome = Incomes(rawValue: Int(sender.selectedMaximum))
    }
    
    @IBAction func incomeCheckChanged(_ sender: M13Checkbox) {
        if !user.isVip {
            showBecomeVIPDialog(forceShow: true)
            sender.checkState = .unchecked
            searchParams.vipIncomeSort = nil
            return
        }
        searchParams.vipIncomeSort = sender.checkState == .checked
    }
    
    @IBAction func datingSortButtonPressed(_ sender: UIButton) {
        guard let clickedUserSortMethod: UserSortMethod = UserSortMethod(rawValue: sender.tag) else { return }
        
        if searchParams.daterSort == clickedUserSortMethod {
            searchParams.daterSort = nil
        } else {
            searchParams.daterSort = clickedUserSortMethod
        }
        refreshScreen()
    }
    
    @IBAction func cupidSortButtonPressed(_ sender: UIButton) {
        guard let clickedCupidSortMethod: CupidSortMethod = CupidSortMethod(rawValue: sender.tag) else { return }
        
        if searchParams.matchmakerSort == clickedCupidSortMethod {
            searchParams.matchmakerSort = nil
        } else {
            searchParams.matchmakerSort = clickedCupidSortMethod
        }
        refreshScreen()
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        let vc = StoryboardManager.loadViewController(storyboard: "Search", viewControllerId: "BaseLocationPickerViewController") as! BaseLocationPickerViewController
        vc.showCurrentLocationButton = true
        vc.useCurrentLocationAsHint = true
        vc.selectCurrentLocationInitially = true
        vc.mapType = .standard
        vc.completion = { [weak self] location in
            guard let self = self, let location = location else { return }
            
            let city = location.placemark.city?.capitalizingFirstLetter() ?? ""
            let country = location.placemark.country?.capitalizingFirstLetter() ?? ""
            let lat = location.location.coordinate.latitude
            let long = location.location.coordinate.longitude
            self.searchParams.location = GPSLocation(coordinates: [lat, long])
            self.searchParams.cityName = "\(city), \(country)"
            self.refreshScreen()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clearPressed(_ sender: UIBarButtonItem) {
        searchParams = UserQueryParams()
        refreshScreen()
    }
    
    private func showVIPDialog() {
        if !user.isVip {
            
            if let lastShownDate = appSettings.getLastShownVIPDialogTime(), lastShownDate > Date().getPastOrFutureDate(min: -MinutesBeforeShowVIPDialogAgain) {
                print("Last Shown Date: \(lastShownDate), don't show VIP dialog for now.")
            } else {
                showBecomeVIPDialog(forceShow: false)
            }
            
        }
    }
}
