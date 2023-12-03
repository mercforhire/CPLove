//
//  VIPHomeViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-26.
//

import UIKit
import Fakery

class VIPHomeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButton: UIButton!
    
    var selected: Product? {
        didSet {
            tableView.reloadData()
            
            if selected == nil {
                continueButton.isHidden = true
            } else {
                continueButton.isHidden = false
            }
        }
    }
    var products: [Product]?
    
    override func setup() {
        super.setup()
        
        selected = { self.selected }()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadProducts()
    }

    private func loadProducts() {
        FullScreenSpinner().show()
        api.getProductPage { [weak self] result in
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if let products = response.data?.records {
                    self?.products = products
                    self?.tableView.reloadData()
                } else {
                    showErrorDialog(code: response.code)
                }
            case .failure(let error):
                guard let _ = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                error.showErrorDialog()
            }
        }
    }
    
    @IBAction func purchasePressed(_ sender: UIButton) {
        guard let product = selected else { return }
        
        let params = product.toSaveOrderRecordParams(currency: "CAD",
                                                      orderId: faker.bank.iban(),
                                                      orderStatus: 0)
        FullScreenSpinner().show()
        userManager.saveOrderRecord(params: params) { [weak self] success in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            if success {
                self.performSegue(withIdentifier: "goToSuccess", sender: self)
            }
        }
    }
    
    @objc private func viewDetailsPressed(_ sender: UIButton) {
        guard let products = products else {
            return
        }
        
        let product = products[sender.tag]
        selected = product
        performSegue(withIdentifier: "goToDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? VIPProductViewController {
            vc.product = selected
        }
    }
}

extension VIPHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (products?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "VIPHeaderCell", for: indexPath) as? VIPHeaderCell else {
                return VIPHeaderCell()
            }
            cell.selectionStyle = .none
            return cell
            
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "VIPProductCell", for: indexPath) as? VIPProductCell, let product = products?[indexPath.row - 1] else {
                return VIPProductCell()
            }
            cell.config(data: product, selected: product.name == selected?.name)
            cell.detailsButton.tag = indexPath.row - 1
            cell.detailsButton.addTarget(self, action: #selector(viewDetailsPressed), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let products = products, indexPath.row >= 1 {
            let product = products[indexPath.row - 1]
            selected = product
        }
    }
}
