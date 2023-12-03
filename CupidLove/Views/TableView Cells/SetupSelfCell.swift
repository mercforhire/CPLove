//
//  SetupSelfCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-21.
//

import UIKit

protocol SetupSelfCellDelegate: class {
    func nameChanged(name: String)
    func yearChanged(year: Int)
    func horoscopeChanged(horoscope: Horoscopes)
    func heightChanged(height: HeightSelections)
    func bodyTypeChanged(bodyType: String)
    func ethnicityChanged(ethnicity: Ethnicities)
    func religionChanged(religion: Religions)
    func locationChanged(city: String, country: String, coordinates: [Double])
    func genderChanged(gender: GenderChoice)
}

class SetupSelfCell: UITableViewCell {
    @IBOutlet weak var nameField: ThemeBorderTextField!
    @IBOutlet weak var horoscopeField: ThemeBorderTextField!
    @IBOutlet weak var yearField: ThemeBorderTextField!
    @IBOutlet weak var heightField: ThemeBorderTextField?
    @IBOutlet weak var bodyTypeField: ThemeBorderTextField?
    @IBOutlet weak var ethnicityField: ThemeBorderTextField!
    @IBOutlet weak var genderField: ThemeBorderTextField?
    @IBOutlet weak var religionField: ThemeBorderTextField!
    @IBOutlet weak var cityField: ThemeBorderTextField!
    
    weak var parentVC: UIViewController?
    weak var delegate: SetupSelfCellDelegate?
    
    private let genderPickerView = UIPickerView()
    private let horoscopePickerView = UIPickerView()
    private let heightPickerView = UIPickerView()
    private let bodyTypePickerView = UIPickerView()
    private let ethnicitiesPickerView = UIPickerView()
    private let religionsPickerView = UIPickerView()
    
    var horoscope: Horoscopes? {
        didSet {
            if let horoscope = horoscope {
                horoscopeField.text = horoscope.title()
            } else {
                horoscopeField.text = ""
            }
        }
    }
    
    var height: HeightSelections? {
        didSet {
            if let height = height {
                heightField?.text = height.title()
            } else {
                heightField?.text = ""
            }
        }
    }
    
    var bodyType: String? {
        didSet {
            bodyTypeField?.text = bodyType
        }
    }
    
    var ethnicity: Ethnicities? {
        didSet {
            if let ethnicity = ethnicity {
                ethnicityField.text = ethnicity.title()
            } else {
                ethnicityField.text = ""
            }
        }
    }
    
    var gender: GenderChoice? {
        didSet {
            if let gender = gender {
                genderField?.text = gender.title()
            } else {
                genderField?.text = ""
            }
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        yearField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(cityFieldPressed(_:)))
        cityField.addGestureRecognizer(tap)
        
        horoscopePickerView.delegate = self
        horoscopePickerView.dataSource = self
        horoscopeField.inputView = horoscopePickerView
        horoscopeField.delegate = self
        
        heightPickerView.delegate = self
        heightPickerView.dataSource = self
        heightField?.inputView = heightPickerView
        heightField?.delegate = self
        
        bodyTypePickerView.delegate = self
        bodyTypePickerView.dataSource = self
        bodyTypeField?.inputView = bodyTypePickerView
        bodyTypeField?.delegate = self
        
        ethnicitiesPickerView.delegate = self
        ethnicitiesPickerView.dataSource = self
        ethnicityField.inputView = ethnicitiesPickerView
        ethnicityField.delegate = self
        
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        genderField?.inputView = genderPickerView
        genderField?.delegate = self
        
        religionsPickerView.delegate = self
        religionsPickerView.dataSource = self
        religionField.inputView = religionsPickerView
        religionField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(updateParams: UpdateUserParams, parentVC: UIViewController) {
        self.nameField.text = updateParams.firstName
        self.yearField.text = updateParams.birthYear != nil ? "\(updateParams.birthYear!)" : nil
        self.cityField.text = "\(updateParams.cityName ?? ""), \(updateParams.countryName ?? "")"
        self.horoscope = updateParams.horoscope
        self.height = updateParams.height
        self.bodyType = updateParams.bodyType
        self.ethnicity = updateParams.ethnicity
        self.religion = updateParams.religion
        self.gender = updateParams.gender
        self.parentVC = parentVC
    }
    
    @objc private func textFieldDidChange(_ textfield: UITextField) {
        if textfield == nameField {
            delegate?.nameChanged(name: textfield.text ?? "")
        } else if textfield == yearField {
            delegate?.yearChanged(year: textfield.text?.int ?? 0)
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
            let lat = location.location.coordinate.latitude
            let long = location.location.coordinate.longitude
            
            self.cityField.text = "\(city), \(country)"
            self.delegate?.locationChanged(city: city, country: country, coordinates: [lat, long])
        }
        parentVC?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SetupSelfCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == horoscopePickerView {
            return Horoscopes.list().count
        } else if pickerView == heightPickerView {
            return HeightSelections.list().count
        } else if pickerView == bodyTypePickerView {
            return BodyTypes.list().count
        } else if pickerView == ethnicitiesPickerView {
            return Ethnicities.list().count
        } else if pickerView == religionsPickerView {
            return Religions.list().count
        } else if pickerView == genderPickerView {
            return GenderChoice.list().count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == horoscopePickerView {
            return Horoscopes.list()[row].selections()
        } else if pickerView == heightPickerView {
            return HeightSelections.list()[row].title()
        } else if pickerView == bodyTypePickerView {
            return BodyTypes.list()[row].title()
        } else if pickerView == ethnicitiesPickerView {
            return Ethnicities.list()[row].title()
        } else if pickerView == religionsPickerView {
            return Religions.list()[row].title()
        } else if pickerView == genderPickerView {
            return GenderChoice.list()[row].title()
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == horoscopePickerView {
            horoscope = Horoscopes.list()[row]
            delegate?.horoscopeChanged(horoscope: horoscope!)
        } else if pickerView == heightPickerView {
            height = HeightSelections.list()[row]
            delegate?.heightChanged(height: height!)
        } else if pickerView == bodyTypePickerView {
            bodyType = BodyTypes.list()[row].title()
            delegate?.bodyTypeChanged(bodyType: bodyType!)
        } else if pickerView == ethnicitiesPickerView {
            ethnicity = Ethnicities.list()[row]
            delegate?.ethnicityChanged(ethnicity: ethnicity!)
        } else if pickerView == religionsPickerView {
            religion = Religions.list()[row]
            delegate?.religionChanged(religion: religion!)
        } else if pickerView == genderPickerView {
            gender = GenderChoice.list()[row]
            delegate?.genderChanged(gender: gender!)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Lato-Regular", size: 19.0)
            pickerLabel?.textAlignment = .center
        }
        if pickerView == horoscopePickerView {
            pickerLabel?.text = Horoscopes.list()[row].selections()
        } else if pickerView == heightPickerView {
            pickerLabel?.text = HeightSelections.list()[row].title()
        } else if pickerView == bodyTypePickerView {
            pickerLabel?.text = BodyTypes.list()[row].title()
        } else if pickerView == ethnicitiesPickerView {
            pickerLabel?.text = Ethnicities.list()[row].title()
        } else if pickerView == genderPickerView {
            pickerLabel?.text = GenderChoice.list()[row].title()
        } else if pickerView == religionsPickerView {
            pickerLabel?.text = Religions.list()[row].title()
        }
        pickerLabel?.textColor = ThemeManager.shared.themeData!.textLabel.hexColor
        return pickerLabel!
    }
}

extension SetupSelfCell: UITextFieldDelegate {
   func textFieldDidBeginEditing(_ textField: UITextField) {
       if textField == horoscopeField, horoscope == nil {
           horoscopePickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(horoscopePickerView, didSelectRow: 0, inComponent: 0)
       }
       else if textField == heightField, height == nil{
           heightPickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(heightPickerView, didSelectRow: 0, inComponent: 0)
       }
       else if textField == bodyTypeField, bodyType == nil{
           bodyTypePickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(bodyTypePickerView, didSelectRow: 0, inComponent: 0)
       }
       else if textField == ethnicityField, ethnicity == nil{
           ethnicitiesPickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(ethnicitiesPickerView, didSelectRow: 0, inComponent: 0)
       }
       else if textField == genderField, gender == nil{
           genderPickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(genderPickerView, didSelectRow: 0, inComponent: 0)
       }
       else if textField == religionField, religion == nil{
           religionsPickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(religionsPickerView, didSelectRow: 0, inComponent: 0)
       }
   }
}
