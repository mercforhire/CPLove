//
//  GetStartedViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-08.
//

import UIKit
import SwiftUI

enum GetStartedSteps: Int {
    case one
    case two
    case three
    case count
    
    func verticalImage() -> Bool {
        switch self {
        case .one:
            return true
        case .two:
            return true
        case .three:
            return false
        default:
            fatalError()
        }
    }
    
    func image() -> UIImage {
        switch self {
        case .one:
            return UIImage(named: "illustration_rose")!
        case .two:
            return UIImage(named: "illustration_woman")!
        case .three:
            return UIImage(named: "illustration_matchmaker")!
        default:
            fatalError()
        }
    }
    
    func title() -> String{
        switch self {
        case .one:
            return "Welcome!!"
        case .two:
            return "Let's get cheeky!"
        case .three:
            return "Join as CP Cupid!"
        default:
            fatalError()
        }
    }
    
    func titleColor() -> UIColor {
        switch self {
        case .one:
            return ThemeManager.shared.themeData!.pink.hexColor
        case .two:
            return ThemeManager.shared.themeData!.pink.hexColor
        case .three:
            return ThemeManager.shared.themeData!.blue.hexColor
        default:
            fatalError()
        }
    }
    
    func body1() -> String{
        switch self {
        case .one:
            return "Look forward but never wait!"
        case .two:
            return "Exciting opportunities to meet in real life!"
        case .three:
            return "Love to bring people together? Become a CP love matchmaker!"
        default:
            fatalError()
        }
    }
    
    func body2() -> String{
        switch self {
        case .one:
            return "CP Love has the smartest bow for your perfect partner!"
        case .two:
            return "Dive in all the fun and efficiency of in-person networking events brought to your doorstep."
        case .three:
            return "Indulge our love-seekers to find someone special. I know you have an unparalleled selection of the daters they want to meet."
        default:
            fatalError()
        }
    }
}

class GetStartedViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var verticalImageView: UIImageView!
    @IBOutlet weak var horizontalImageView: UIImageView!
    private var page: Int = 0 {
        didSet {
            collectionView.scrollToItem(at: IndexPath(row: page, section: 0), at: .left, animated: true)
            
            if page == (GetStartedSteps.count.rawValue - 1) {
                nextButton.setTitle("Start", for: .normal)
            }
            
            let step: GetStartedSteps = GetStartedSteps(rawValue: page)!
            if step.verticalImage() {
                verticalImageView.isHidden = false
                horizontalImageView.isHidden = true
            } else {
                verticalImageView.isHidden = true
                horizontalImageView.isHidden = false
            }
            
            verticalImageView.image = step.image()
            horizontalImageView.image = step.image()
        }
    }
    
    override func setup() {
        super.setup()
        
        navigationController?.navigationBar.isHidden = true
        page = 0
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if appSettings.isGetStartedViewed() {
            let vc = StoryboardManager.loadViewController(storyboard: "Login", viewControllerId: "LoginStep1ViewController") as! LoginStep1ViewController
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.reloadData()
    }

    @IBAction func nextPressed(_ sender: UIButton) {
        if page == (GetStartedSteps.count.rawValue - 1) {
            appSettings.setGetStartedViewed(viewed: true)
            performSegue(withIdentifier: "goToLogin", sender: self)
        } else {
            page = page + 1
        }
    }
}

extension GetStartedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GetStartedSteps.count.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GetStartedCell", for: indexPath) as! GetStartedCell
        
        let step = GetStartedSteps(rawValue: indexPath.row)!
        cell.config(data: step)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
