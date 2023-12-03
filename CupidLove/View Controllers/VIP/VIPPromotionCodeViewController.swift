//
//  VIPPromotionCodeViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-27.
//

import UIKit

class VIPPromotionCodeViewController: BaseViewController {
    
    private enum VIPPromotionCodeSteps: Int {
        case enterCode
        case codeAccepted
        case count
        
        func cellNames() -> [String] {
            switch self {
            case .enterCode:
                return ["PromotionCodeCell"]
            case .codeAccepted:
                return ["PromotionCodeAcceptedCell"]
            default:
                fatalError()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private var step: VIPPromotionCodeSteps = .enterCode {
        didSet {
            tableView.reloadData()
        }
    }
    private var code: String?
    var codeErrorString: String? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var coupon: CouponData? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @objc private func verifyCodePressed(_ sender: UIButton) {
        guard let code = code else { return }

        FullScreenSpinner().show()
        
        api.getVipCouponByCode(coupon: code) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if let coupon = response.data, !coupon.isRedeemed {
                    self.coupon = coupon
                    self.codeErrorString = ""
                } else {
                    self.coupon = nil
                    self.codeErrorString = "Invalid code"
                }
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }
    
    @objc private func submitPressed(_ sender: UIButton) {
        guard let code = code else { return }
        
        FullScreenSpinner().show()

        api.redeemVipCode(vipCode: code) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if let _ = response.data {
                    self.codeErrorString = nil
                    self.step = VIPPromotionCodeSteps(rawValue: min(VIPPromotionCodeSteps.codeAccepted.rawValue, self.step.rawValue + 1)) ?? .codeAccepted
                } else {
                    showErrorDialog(code: response.code)
                    self.codeErrorString = "Invalid code"
                }
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }
    
    @objc private func donePressed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func textFieldDidChange(_ textfield: UITextField) {
        code = textfield.text
    }
}

extension VIPPromotionCodeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return step.cellNames().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stepName = step.cellNames()[indexPath.row]
        
        var tableCell: UITableViewCell!
        
        switch stepName {
        case "PromotionCodeCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? PromotionCodeCell else {
                return PromotionCodeCell()
            }
            if let coupon = coupon {
                if let days = coupon.day {
                    cell.titleLabel.text = "Enter you code and get free \(days) days VIP"
                } else if let months = coupon.month {
                    cell.titleLabel.text = "Enter you code and get free \(months) days VIP"
                } else  {
                    cell.titleLabel.text = "Enter you code and get free VIP membership"
                }
            } else {
                cell.titleLabel.text = "Enter code and get your free VIP membership"
            }
            
            cell.codeField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            cell.verifyButton.addTarget(self, action: #selector(verifyCodePressed(_:)), for: .touchUpInside)
            cell.submitButton.addTarget(self, action: #selector(submitPressed(_:)), for: .touchUpInside)
            if let error = codeErrorString {
                cell.codeErrorLabel.text = error
                cell.codeErrorLabel.isHidden = false
            } else {
                cell.codeErrorLabel.text = ""
                cell.codeErrorLabel.isHidden = true
            }
            cell.submitButton.isEnabled = coupon != nil
            tableCell = cell
        case "PromotionCodeAcceptedCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? PromotionCodeAcceptedCell else {
                return PromotionCodeAcceptedCell()
            }
            cell.doneButton.addTarget(self, action: #selector(donePressed(_:)), for: .touchUpInside)
            tableCell = cell
        default:
            tableCell = UITableViewCell()
        }
        
        return tableCell
    }
}
