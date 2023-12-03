//
//  SetupCareerCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-23.
//

import UIKit

protocol SetupCareerCellDelegate: class {
    func schoolChanged(school: String)
    func jobChanged(job: String)
    func incomeChanged(incomeRange: [Incomes])
}

class SetupCareerCell: UITableViewCell {

    @IBOutlet weak var schoolField: ThemeBorderTextField!
    @IBOutlet weak var jobField: ThemeBorderTextField!
    @IBOutlet weak var incomeField: ThemeBorderTextField!
    
    weak var delegate: SetupCareerCellDelegate?
    
    private let incomePickerView = UIPickerView()
    
    var income: [Incomes]? {
        didSet {
            if let income = income, !income.isEmpty {
                incomeField.text = Incomes.rangeText(range: income)
            } else {
                incomeField.text = ""
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        incomePickerView.delegate = self
        incomePickerView.dataSource = self
        incomeField.inputView = incomePickerView
        incomeField.delegate = self
        
        schoolField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        jobField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(updateParams: UpdateUserParams) {
        self.jobField.text = updateParams.jobTitle
        self.schoolField.text = updateParams.school
        self.income = []
        if let minIncome = updateParams.minIncome {
            self.income?.append(minIncome)
        }
        if let maxIncome = updateParams.maxIncome {
            self.income?.append(maxIncome)
        }
    }
    
    @objc private func textFieldDidChange(_ textfield: UITextField) {
        if textfield == schoolField {
            delegate?.schoolChanged(school: textfield.text ?? "")
        } else if textfield == jobField {
            delegate?.jobChanged(job: textfield.text ?? "")
        }
    }
}

extension SetupCareerCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == incomePickerView {
            return Incomes.ranges().count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == incomePickerView {
            let range = Incomes.ranges()[row]
            return Incomes.rangeText(range: range)
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == incomePickerView {
            income = Incomes.ranges()[row]
            delegate?.incomeChanged(incomeRange: income!)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Lato-Regular", size: 19.0)
            pickerLabel?.textAlignment = .center
        }
        if pickerView == incomePickerView {
            let range = Incomes.ranges()[row]
            pickerLabel?.text = Incomes.rangeText(range: range)
        }
        pickerLabel?.textColor = ThemeManager.shared.themeData!.textLabel.hexColor
        return pickerLabel!
    }
}

extension SetupCareerCell: UITextFieldDelegate {
   func textFieldDidBeginEditing(_ textField: UITextField) {
       if textField == incomeField, income?.isEmpty ?? true {
           incomePickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(incomePickerView, didSelectRow: 0, inComponent: 0)
       }
   }
}
