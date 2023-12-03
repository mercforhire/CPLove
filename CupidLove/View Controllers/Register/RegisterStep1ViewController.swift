//
//  RegisterStep1ViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-15.
//

import UIKit

class RegisterStep1ViewController: BaseViewController {

    private var registerMode: UserTypeMode = .normal
    
    override func setup() {
        super.setup()
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RegisterStep2ViewController {
            vc.type = registerMode
        }
    }

    @IBAction func registerDating(_ sender: Any) {
        registerMode = .normal
        performSegue(withIdentifier: "goToRegister", sender: self)
    }
    
    @IBAction func registerCupid(_ sender: Any) {
        registerMode = .cupid
        performSegue(withIdentifier: "goToRegister", sender: self)
    }
}
