//
//  MyAccountQuestionViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

class QuestionsViewController: BaseTableViewController {
    struct RowData {
        var question: QuestionData
        var answer: QuestionAnswer?
    }
    var data: [RowData] = []
    var selectedIndex: Int?
    
    override func setup() {
        super.setup()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        tableView.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func fetchData() {
        data.removeAll()
        for answer in user.myAnswerDtoList ?? [] {
            if let a = userManager.profileQuestions?.first(where: { $0.identifier == answer.questionId }) {
                let b = QuestionAnswer(questionId: answer.questionId, answer: answer.answer)
                let rowData = RowData(question: a, answer: b)
                data.append(rowData)
            }
        }
        for question in userManager.profileQuestions ?? [] {
            if data.contains(where: { $0.question.identifier == question.identifier }) {
                continue
            }
            data.append(RowData(question: question))
        }
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditQuestionViewController,
            let selectedIndex = selectedIndex {
            vc.question = data[selectedIndex].question
            vc.answer = data[selectedIndex].answer
        }
    }
    
    private func handleDelete() {
        guard let selectedIndex = selectedIndex else { return }
        
        let question = data[selectedIndex].question
        let answer = QuestionAnswer(questionId: question.identifier, answer: nil)
        FullScreenSpinner().show()
        api.updateMyAnswer(answer: answer) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if response.data != nil {
                    self.userManager.updateAnswer(question: question, answer: nil)
                    self.data[selectedIndex].answer = nil
                    self.tableView.reloadData()
                } else {
                    showErrorDialog(code: response.code)
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
    
    private func showQuestionAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: {  _ in
            self.performSegue(withIdentifier: "goToEditQuestion", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {  _ in
            self.handleDelete()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableViewCell", for: indexPath) as? QuestionTableViewCell else {
            return QuestionTableViewCell()
        }
        cell.questionLabel.text = data[indexPath.row].question.question
        if let answer = data[indexPath.row].answer, !(answer.answer?.isEmpty ?? true) {
            cell.answerLabel.isHidden = false
            cell.answerLabel.text = answer.answer
        } else {
            cell.answerLabel.isHidden = true
            cell.answerLabel.text = ""
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        
        if let answer = data[indexPath.row].answer, !(answer.answer?.isEmpty ?? true) {
            showQuestionAction()
        } else {
            performSegue(withIdentifier: "goToEditQuestion", sender: self)
        }
    }
}
