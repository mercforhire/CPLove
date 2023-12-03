//
//  PartnerDetailsCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-19.
//

import UIKit
import UIMultiPicker

protocol PartnerDetailsCellDelegate: class {
    func desiredEthnicitiesChanged(ethnicities: [Ethnicities])
    func desiredCityChanged(city: String)
    func desiredMinAgeChanged(min: Int)
    func desiredMaxAgeChanged(max: Int)
    func desiredReligionChanged(religion: Religions)
    func desiredIncomeChanged(min: Incomes)
    func desiredPersonalities(personalities: [Personality])
}

class PartnerDetailsCell: UITableViewCell {

    weak var parentVC: UIViewController?
    weak var delegate: PartnerDetailsCellDelegate?
    
    @IBOutlet weak var ethnicitiesField: ThemeBorderTextField!
    @IBOutlet weak var cityField: ThemeBorderTextField!
    @IBOutlet weak var minAgeField: ThemeBorderTextField!
    @IBOutlet weak var maxAgeField: ThemeBorderTextField!
    @IBOutlet weak var religionField: ThemeBorderTextField!
    @IBOutlet weak var minIncomeField: ThemeBorderTextField!
    @IBOutlet weak var personalitiesField: ThemeBorderTextField!
    
    private var ethnicitiesPickerView: UIMultiPicker!
    private let religionPickerView = UIPickerView()
    private let minIncomePickerView = UIPickerView()
    private var personalitiesPickerView: UIMultiPicker!
    
    var ethnicities: [Ethnicities]? {
        didSet {
            let ethnicitiesTitles = ethnicities?.map({ $0.title() })
            ethnicitiesField.text = ethnicitiesTitles?.joined(separator: ",")
        }
    }
    
    var religion: Religions? {
        didSet {
            if let religion = religion {
                religionField.text = religion.title()
            } else {
                religionField.text = ""
            }
        }
    }
    
    var minIncome: Incomes? {
        didSet {
            if let minIncome = minIncome {
                minIncomeField.text = minIncome.title()
                delegate?.desiredIncomeChanged(min: minIncome)
            } else {
                minIncomeField.text = ""
            }
        }
    }
    
    var personalities: [Personality]? {
        didSet {
            let personalityTitles = personalities?.map({ $0.title() })
            personalitiesField.text = personalityTitles?.joined(separator: ",")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        ethnicitiesPickerView = UIMultiPicker(frame: CGRect(origin: .zero, size: CGSize(width: self.frame.width, height: 200.0)))
        ethnicitiesPickerView.options = Ethnicities.list().map({ $0.title() })
        ethnicitiesPickerView.font = UIFont(name: "Lato-Regular", size: 19.0)!
        ethnicitiesPickerView.addTarget(self, action: #selector(selectedEthnicities(_:)), for: .valueChanged)
        ethnicitiesField.inputView = ethnicitiesPickerView
        ethnicitiesField.delegate = self
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(cityFieldPressed(_:)))
        cityField.addGestureRecognizer(tap)
        
        minAgeField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        maxAgeField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        religionPickerView.delegate = self
        religionPickerView.dataSource = self
        religionField.inputView = religionPickerView
        religionField.delegate = self
        
        minIncomePickerView.delegate = self
        minIncomePickerView.dataSource = self
        minIncomeField.inputView = minIncomePickerView
        minIncomeField.delegate = self
        
        personalitiesPickerView = UIMultiPicker(frame: CGRect(origin: .zero, size: CGSize(width: self.frame.width, height: 200.0)))
        personalitiesPickerView.options = Personality.list().map({ $0.title() })
        personalitiesPickerView.font = UIFont(name: "Lato-Regular", size: 19.0)!
        personalitiesPickerView.addTarget(self, action: #selector(selectedPersonalities(_:)), for: .valueChanged)
        personalitiesField.inputView = personalitiesPickerView
        personalitiesField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @objc func selectedEthnicities(_ sender: UIMultiPicker) {
        var ethnicities: [Ethnicities] = []
        for selectedIndex in sender.selectedIndexes {
            ethnicities.append(Ethnicities.list()[selectedIndex])
        }
        self.ethnicities = ethnicities
        delegate?.desiredEthnicitiesChanged(ethnicities: ethnicities)
    }
    
    @objc func selectedPersonalities(_ sender: UIMultiPicker) {
        var personalities: [Personality] = []
        for selectedIndex in sender.selectedIndexes {
            personalities.append(Personality.list()[selectedIndex])
        }
        self.personalities = personalities
        delegate?.desiredPersonalities(personalities: personalities)
    }
    
    func config(updateParams: UpdateUserParams) {
        ethnicities = updateParams.desiredEthnicity ?? []
        
        if let city = updateParams.desiredCityName {
            cityField.text = "\(city)"
        }
        
        if let minAge = updateParams.desiredMinAge {
            minAgeField.text = "\(minAge)"
        }
        
        if let maxAge = updateParams.desiredMaxAge {
            maxAgeField.text = "\(maxAge)"
        }
        
        religion = updateParams.desiredReligion?.first
        minIncome = updateParams.desiredMinIncome
        personalities = updateParams.desiredPersonality ?? []
    }
    
    @objc private func textFieldDidChange(_ textfield: UITextField) {
        if textfield == minAgeField, let min = minAgeField.text?.int {
            delegate?.desiredMinAgeChanged(min: min)
        } else if textfield == maxAgeField, let max = maxAgeField.text?.int {
            delegate?.desiredMaxAgeChanged(max: max)
        }
    }
    
    @objc func cityFieldPressed(_ sender: UITapGestureRecognizer) {
        let vc = StoryboardManager.loadViewController(storyboard: "Search", viewControllerId: "BaseLocationPickerViewController") as! BaseLocationPickerViewController
        vc.showCurrentLocationButton = true
        vc.useCurrentLocationAsHint = true
        vc.selectCurrentLocationInitially = true
        vc.mapType = .standard
        vc.completion = { [weak self] location in
            guard let self = self, let location = location else { return }
            
            let city = location.placemark.city?.capitalizingFirstLetter() ?? ""
            let country = location.placemark.country?.capitalizingFirstLetter() ?? ""
            self.cityField.text = "\(city), \(country)"
            self.delegate?.desiredCityChanged(city: city)
        }
        parentVC?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PartnerDetailsCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == religionPickerView {
            return Religions.list().count
        } else if pickerView == minIncomePickerView {
            return Incomes.partnerSelections().count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == religionPickerView {
            return Religions.list()[row].title()
        } else if pickerView == minIncomePickerView {
            return Incomes.partnerSelections()[row].title()
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == religionPickerView {
            religion = Religions.list()[row]
            delegate?.desiredReligionChanged(religion: religion!)
        } else if pickerView == minIncomePickerView {
            minIncome = Incomes.partnerSelections()[row]
            delegate?.desiredIncomeChanged(min: minIncome!)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Lato-Regular", size: 19.0)
            pickerLabel?.textAlignment = .center
        }

        if pickerView == religionPickerView {
            pickerLabel?.text = Religions.list()[row].title()
        } else if pickerView == minIncomePickerView {
            pickerLabel?.text = Incomes.partnerSelections()[row].title()
        }
        
        pickerLabel?.textColor = ThemeManager.shared.themeData!.textLabel.hexColor
        return pickerLabel!
    }
}

extension PartnerDetailsCell: UITextFieldDelegate {
   func textFieldDidBeginEditing(_ textField: UITextField) {
       if textField == ethnicitiesField, ethnicities == nil {
           ethnicitiesPickerView.selectedIndexes = [0]
       }
       else if textField == religionField, religion == nil{
           religionPickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(religionPickerView, didSelectRow: 0, inComponent: 0)
       }
       else if textField == minIncomeField, minIncome == nil{
           minIncomePickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(minIncomePickerView, didSelectRow: 0, inComponent: 0)
       }
       else if textField == personalitiesField, personalities == nil{
           personalitiesPickerView.selectedIndexes = [0]
       }
   }
}
