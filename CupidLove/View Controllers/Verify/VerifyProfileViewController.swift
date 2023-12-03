//
//  VerifyProfileViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-05.
//

import UIKit
import PhotosUI
import Mantis

class VerifyProfileViewController: BaseViewController {

    private enum VerifySteps: Int {
        case instructions
        case photo
        case verifying
        case count
        
        func cellNames() -> [String] {
            switch self {
            case .instructions:
                return ["VerifyStep1Cell"]
            case .photo:
                return ["VerifyStep2Cell"]
            case .verifying:
                return ["VerifyStep3Cell"]
            default:
                fatalError()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private var step: VerifySteps = .instructions {
        didSet {
            tableView.reloadData()
        }
    }
    private var photo: UIImage? {
        didSet {
            if photo != nil {
                step = .photo
            } else {
                step = .instructions
            }
        }
    }
    private var imagePicker: ImagePicker!
    
    override func setup() {
        super.setup()
        
        imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @objc private func getStartedPressed(_ sender: UIButton) {
        requestPhotoPermission { [weak self] hasPermission in
            guard let self = self else { return }

            if hasPermission {
                self.getImageOrVideoFromAlbum(sourceView: self.view)
            } else {
                showErrorDialog(error: "Please enable photo access for this app in the phone settings.")
            }
        }
    }
    
    @objc private func confirmPressed(_ sender: UIButton) {
        step = .verifying
    }
    
    @objc private func donePressed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }

    private func showMantis(image: UIImage) {
        var config = Mantis.Config()
        config.cropToolbarConfig.toolbarButtonOptions = [.clockwiseRotate, .reset, .ratio, .alterCropper90Degree];
        
        let cropViewController = Mantis.cropViewController(image: image, config: config)
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.delegate = self
        present(cropViewController, animated: true)
    }
    
    private func getImageOrVideoFromAlbum(sourceView: UIView) {
        imagePicker.present(from: sourceView, cameraOnly: true)
    }
    
    private func uploadPhoto(photo: UIImage) {
        self.photo = photo
    }
}

extension VerifyProfileViewController: UITableViewDataSource, UITableViewDelegate {
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
        case "VerifyStep1Cell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? VerifyStep1Cell else {
                return VerifyStep1Cell()
            }
            cell.button.addTarget(self, action: #selector(getStartedPressed(_:)), for: .touchUpInside)
            tableCell = cell
        case "VerifyStep2Cell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? VerifyStep2Cell else {
                return VerifyStep2Cell()
            }
            cell.photoImageView?.image = photo
            cell.retakeButton.addTarget(self, action: #selector(getStartedPressed(_:)), for: .touchUpInside)
            cell.confirmButton.addTarget(self, action: #selector(confirmPressed(_:)), for: .touchUpInside)
            tableCell = cell
        case "VerifyStep3Cell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? VerifyStep3Cell else {
                return VerifyStep3Cell()
            }
            cell.button.addTarget(self, action: #selector(donePressed(_:)), for: .touchUpInside)
            tableCell = cell
        default:
            tableCell = UITableViewCell()
        }
        
        return tableCell
    }
}

extension VerifyProfileViewController: ImagePickerDelegate {
    func didSelectImage(image: UIImage?) {
        guard let image = image else {
            return
        }
        
        showMantis(image: image)
    }
    
    func didSelectVideo(video: PHAsset?) {
        
    }
}

extension VerifyProfileViewController: CropViewControllerDelegate {
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        
    }
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
        
    }
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        print(transformation);
        dismiss(animated: true, completion: { [weak self] in
            self?.uploadPhoto(photo: cropped)
        })
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        dismiss(animated: true)
    }
}
