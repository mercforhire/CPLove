//
//  InviteCodeViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-12.
//

import UIKit

class InviteCodeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var code: String!
    
    lazy var composer: MessageComposer = MessageComposer()
    
    override func setup() {
        super.setup()
        
        code = user.inviteCode
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @objc private func copyPressed(_ sender: UIButton) {
        UIPasteboard.general.string = code
        
        showErrorDialog(error: "Code has been copied to pasteboard!")
    }
    
    @objc private func emailPressed(_ sender: UIButton) {
        guard composer.canSendEmail() else {
            showErrorDialog(error: "Can't send email on this device.")
            return
        }
        
        let vc = composer.configuredEmailComposeViewController(subject: "CL Love app invite",
                                                               message: "Register using code: \(code ?? "")")
        present(vc, animated: true)
    }
    
    @objc private func smsPressed(_ sender: UIButton) {
        guard composer.canSendText() else {
            showErrorDialog(error: "Can't send SMS on this device.")
            return
        }
        
        let vc = composer.configuredMessageComposeViewController(message: "Download CPLove app and register using code: \(code ?? "")")
        present(vc, animated: true)
    }
}

extension InviteCodeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCodeTableViewCell", for: indexPath) as? InviteCodeTableViewCell else {
            return InviteCodeTableViewCell()
        }
        cell.codeField.text = code
        cell.copyButton.addTarget(self, action: #selector(copyPressed), for: .touchUpInside)
        cell.emailButton.addTarget(self, action: #selector(emailPressed), for: .touchUpInside)
        cell.smsButton.addTarget(self, action: #selector(smsPressed), for: .touchUpInside)
        return cell
    }
}
