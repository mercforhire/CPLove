//
//  LoginStep2ViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-15.
//

import UIKit

class LoginStep2ViewController: BaseViewController {

    private var loginMode: UserTypeMode = .normal
    
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
        if let vc = segue.destination as? LoginStep3ViewController {
            vc.type = loginMode
        }
    }
    
    @IBAction func loginDate(_ sender: Any) {
        loginMode = .normal
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
    
    @IBAction func loginCupid(_ sender: Any) {
        loginMode = .cupid
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
}
