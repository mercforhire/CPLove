//
//  SetupAssetsCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-27.
//

import UIKit
import UIMultiPicker

protocol SetupAssetsCellDelegate: class {
    func assetsChanged(assets: [Assets])
    func siblingsChanged(siblings: Siblings)
    func childPreferenceChanged(preference: ChildPreference)
}

class SetupAssetsCell: UITableViewCell {
    
    @IBOutlet weak var assetsField: ThemeBorderTextField!
    @IBOutlet weak var siblingsField: ThemeBorderTextField!
    @IBOutlet weak var childField: ThemeBorderTextField!
    
    weak var delegate: SetupAssetsCellDelegate?
    
    private var assetsPickerView: UIMultiPicker!
    private let familyPickerView = UIPickerView()
    private let childPickerView = UIPickerView()
    
    var assets: [Assets]? {
        didSet {
            let assetsTitles = assets?.map({ $0.title() })
            assetsField.text = assetsTitles?.joined(separator: ",")
        }
    }
    
    var siblings: Siblings? {
        didSet {
            if let siblings = siblings {
                siblingsField.text = siblings.title()
            } else {
                siblingsField.text = ""
            }
        }
    }
    
    var childPreference: ChildPreference? {
        didSet {
            if let childPreference = childPreference {
                childField.text = childPreference.title()
            } else {
                childField.text = ""
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        assetsPickerView = UIMultiPicker(frame: CGRect(origin: .zero, size: CGSize(width: self.frame.width, height: 200.0)))
        assetsPickerView.options = Assets.list().map({ $0.title() })
        assetsPickerView.font = UIFont(name: "Lato-Regular", size: 19.0)!
        assetsPickerView.addTarget(self, action: #selector(selectedAssets(_:)), for: .valueChanged)
        assetsField.inputView = assetsPickerView
        assetsField.delegate = self
        
        familyPickerView.delegate = self
        familyPickerView.dataSource = self
        siblingsField.inputView = familyPickerView
        siblingsField.delegate = self
        
        childPickerView.delegate = self
        childPickerView.dataSource = self
        childField.inputView = childPickerView
        childField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func selectedAssets(_ sender: UIMultiPicker) {
        var assets: [Assets] = []
        for selectedIndex in sender.selectedIndexes {
            assets.append(Assets.list()[selectedIndex])
        }
        self.assets = assets
        delegate?.assetsChanged(assets: assets)
    }
    
    func config(updateParams: UpdateUserParams) {
        assets = updateParams.asset ?? []
        siblings = updateParams.sibling
        childPreference = updateParams.child
    }
}

extension SetupAssetsCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == familyPickerView {
            return Siblings.list().count
        } else if pickerView == childPickerView {
            return ChildPreference.list().count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == familyPickerView {
            return Siblings.list()[row].title()
        } else if pickerView == childPickerView {
            return ChildPreference.list()[row].title()
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == familyPickerView {
            siblings = Siblings.list()[row]
            delegate?.siblingsChanged(siblings: siblings!)
        } else if pickerView == childPickerView {
            childPreference = ChildPreference.list()[row]
            delegate?.childPreferenceChanged(preference: childPreference!)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Lato-Regular", size: 19.0)
            pickerLabel?.textAlignment = .center
        }
        if pickerView == familyPickerView {
            pickerLabel?.text = Siblings.list()[row].title()
        } else if pickerView == childPickerView {
            pickerLabel?.text = ChildPreference.list()[row].title()
        }
        pickerLabel?.textColor = ThemeManager.shared.themeData!.textLabel.hexColor
        return pickerLabel!
    }
}

extension SetupAssetsCell: UITextFieldDelegate {
   func textFieldDidBeginEditing(_ textField: UITextField) {
       if textField == assetsField, assets?.isEmpty ?? true {
           assetsPickerView.selectedIndexes = [0]
       }
       else if textField == siblingsField, siblings == nil{
           familyPickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(familyPickerView, didSelectRow: 0, inComponent: 0)
       }
       else if textField == childField, childPreference == nil{
           childPickerView.selectRow(0, inComponent: 0, animated: true)
           pickerView(childPickerView, didSelectRow: 0, inComponent: 0)
       }
   }
}
