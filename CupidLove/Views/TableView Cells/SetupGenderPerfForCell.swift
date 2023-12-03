//
//  SetupGenderPerfForCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-23.
//

import UIKit

protocol SetupGenderPerfForCellDelegate: class {
    func genderChanged(gender: GenderChoice)
    func dateGenderChanged(dateGender: GenderChoice)
    func lookingForChanged(lookingFor: RelationshipTypes)
}

class SetupGenderPerfForCell: UITableViewCell {
    
    @IBOutlet weak var genderField: ThemeBorderTextField!
    @IBOutlet weak var dateGenderField: ThemeBorderTextField!
    @IBOutlet weak var lookingForField: ThemeBorderTextField!
    
    weak var delegate: SetupGenderPerfForCellDelegate?
    
    private let genderPickerView = UIPickerView()
    private let lookforGenderPickerView = UIPickerView()
    private let relationshipPickerView = UIPickerView()
    
    var gender: GenderChoice? {
        didSet {
            if let gender = gender {
                genderField.text = gender.title()
            } else {
                genderField.text = ""
            }
        }
    }
    
    var dateGender: GenderChoice? {
        didSet {
            if let dateGender = dateGender {
                dateGenderField.text = dateGender.title()
            } else {
                dateGenderField.text = ""
            }
        }
    }
    
    var lookingFor: RelationshipTypes? {
        didSet {
            if let lookingFor = lookingFor {
                lookingForField.text = lookingFor.title()
            } else {
                lookingForField.text = ""
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        genderField.inputView = genderPickerView
        genderField.delegate = self
        
        lookforGenderPickerView.delegate = self
        lookforGenderPickerView.dataSource = self
        dateGenderField.inputView = lookforGenderPickerView
        dateGenderField.delegate = self
        
        relationshipPickerView.delegate = self
        relationshipPickerView.dataSource = self
        lookingForField.inputView = relationshipPickerView
        lookingForField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(updateParams: UpdateUserParams) {
        gender = updateParams.gender
        dateGender = updateParams.dateGender
        lookingFor = updateParams.lookingFor
    }
}

extension SetupGenderPerfForCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == genderPickerView {
            return GenderChoice.list().count
        } else if pickerView == lookforGenderPickerView {
            return GenderChoice.list().count
        } else if pickerView == relationshipPickerView {
            return RelationshipTypes.list().count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == genderPickerView {
            return GenderChoice.list()[row].title()
        } else if pickerView == lookforGenderPickerView {
            return GenderChoice.list()[row].title()
        } else if pickerView == relationshipPickerView {
            return RelationshipTypes.list()[row].title()
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genderPickerView {
            gender = GenderChoice.list()[row]
            delegate?.genderChanged(gender: gender!)
        } else if pickerView == lookforGenderPickerView {
            dateGender = GenderChoice.list()[row]
            delegate?.dateGenderChanged(dateGender: dateGender!)
        } else if pickerView == relationshipPickerView {
            lookingFor = RelationshipTypes.list()[row]
            delegate?.lookingForChanged(lookingFor: lookingFor!)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Lato-Regular", size: 19.0)
            pickerLabel?.textAlignment = .center
        }
        if pickerView == genderPickerView {
            pickerLabel?.text = GenderChoice.list()[row].title()
        } else if pickerView == lookforGenderPickerView {
            pickerLabel?.text = GenderChoice.list()[row].title()
        } else if pickerView == relationshipPickerView {
            pickerLabel?.text = RelationshipTypes.list()[row].title()
        }
        pickerLabel?.textColor = ThemeManager.shared.themeData!.textLabel.hexColor
        return pickerLabel!
    }
}

extension SetupGenderPerfForCell: UITextFieldDelegate {
   func textFieldDidBeginEditing(_ textField: UITextField) {
       if textField == genderField, gender == nil {
           genderPickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(genderPickerView, didSelectRow: 0, inComponent: 0)
       }
       else if textField == dateGenderField, dateGender == nil{
           lookforGenderPickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(lookforGenderPickerView, didSelectRow: 0, inComponent: 0)
       }
       else if textField == lookingForField, lookingFor == nil{
           relationshipPickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(relationshipPickerView, didSelectRow: 0, inComponent: 0)
       }
   }
}
