//
//  VIPProductViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-26.
//

import UIKit

class VIPProductViewController: BaseViewController {
    var product: Product!

    @IBOutlet weak var productPictureContainer: UIView!
    @IBOutlet weak var productPicture: UIImageView!
    @IBOutlet weak var label1: ThemeBlackTextLabel!
    @IBOutlet weak var label2: ThemeBlackTextLabel!
    @IBOutlet weak var label3: ThemeBlackTextLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!

    override func setup() {
        super.setup()
        
        productPicture.roundCorners(style: .completely)
        tableView.rowHeight = ProductFeatureCell.FixedHeight
        productPictureContainer.addShadow(style: .completely)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadProduct()
    }
    
    private func loadProduct() {
        title = product.name
        productPicture.image = UIImage(named: product.iconName ?? "grass")
        label1.text = product.name
        label2.text = "$\(String(format: "%.2f", product.price))"
        label3.text = " / \(product.amount) \(product.unit)"
        tableView.reloadData()
        tableViewHeight.constant = CGFloat(product.detail?.count ?? 0) * ProductFeatureCell.FixedHeight
    }

    @IBAction func selectPressed(_ sender: UIButton) {
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
}

extension VIPProductViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return product.detail?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductFeatureCell", for: indexPath) as? ProductFeatureCell else {
            return ProductFeatureCell()
        }
        
        let description = product.detail?[indexPath.row]
        cell.label.text = description
        return cell
    }
}
