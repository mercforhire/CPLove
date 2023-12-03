//
//  SetupUploadPhotosCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-13.
//

import UIKit
import PhotosUI
import Mantis

protocol SetupUploadPhotosCellDelegate: class {
    func profileImagesChanged(profileImages: [PhotoResponse])
    func imagesChanged(images: [UIImage])
}

class SetupUploadPhotosCell: UITableViewCell {
    weak var parentVC: UIViewController? {
        didSet {
            guard let parentVC = parentVC else { return }
            
            imagePicker = ImagePicker(presentationController: parentVC,
                                      delegate: self)
        }
    }
    weak var userManager: UserManager?
    weak var delegate: SetupUploadPhotosCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet var imageViews: [URLImageView]!
    @IBOutlet var frames: [UIImageView]!
    @IBOutlet var plusButtons: [UIButton]!
    
    private var profileImages: [PhotoResponse]? {
        didSet {
            guard let profileImages = profileImages else { return }
            
            for index in 0..<4 {
                if index >= profileImages.count {
                    if let imageView = getImageView(index: index), let plusButton = getPlusButtons(index: index) {
                        imageView.image = nil
                        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
                    }
                } else {
                    if let imageView = getImageView(index: index), let plusButton = getPlusButtons(index: index) {
                        imageView.loadImageFromURL(urlString: profileImages[index].thumbnailUrl, blur: .none)
                        plusButton.setImage(UIImage(systemName: "minus"), for: .normal)
                    }
                }
            }
        }
    }
    private var images: [UIImage]? {
        didSet {
            guard let images = images else { return }
            
            for index in 0..<4 {
                if index >= images.count {
                    if let imageView = getImageView(index: index), let plusButton = getPlusButtons(index: index) {
                        imageView.image = nil
                        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
                    }
                } else {
                    if let imageView = getImageView(index: index), let plusButton = getPlusButtons(index: index) {
                        imageView.image = images[index]
                        plusButton.setImage(UIImage(systemName: "minus"), for: .normal)
                    }
                }
            }
        }
    }
    
    private var imagePicker: ImagePicker!
    
    private func getImageView(index: Int) -> URLImageView? {
        return imageViews.filter { $0.tag == index }.first
        
    }
    
    private func getPlusButtons(index: Int) -> UIButton? {
        return plusButtons.filter { $0.tag == index }.first
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        for imageView in imageViews {
            imageView.roundCorners(style: .medium)
        }
        
        for plusButton in plusButtons {
            plusButton.roundCorners(style: .completely)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(updateParams: UpdateUserParams, userManager: UserManager) {
        profileImages = updateParams.personalPhotos ?? []
        self.userManager = userManager
    }
    
    func config(profileImages: [UIImage]) {
        self.images = profileImages
    }
    
    @IBAction private func pickPhoto(_ sender: UIButton) {
        let index = sender.tag
        if profileImages != nil {
            let currentPhotosCount = profileImages!.count

            if index >= currentPhotosCount {
                requestPhotoPermission { [weak self] hasPermission in
                    guard let self = self else { return }

                    if hasPermission {
                        self.getImageOrVideoFromAlbum(sourceView: sender)
                    } else {
                        showErrorDialog(error: "Please enable photo library access for this app in the phone settings.")
                    }
                }
            } else {
                FullScreenSpinner().show()
                userManager!.deleteProfilePhoto(index: index, updateProfile: false, completion: { [weak self] success in
                    guard let self = self else { return }
                    
                    FullScreenSpinner().hide()
                    if success {
                        self.profileImages!.remove(at: index)
                        self.delegate?.profileImagesChanged(profileImages: self.profileImages!)
                    } else {
                        showErrorDialog(error: "Failed to delete photo")
                    }
                })
            }
        } else if images != nil {
            let currentPhotosCount = images!.count

            if index >= currentPhotosCount {
                requestPhotoPermission { [weak self] hasPermission in
                    guard let self = self else { return }

                    if hasPermission {
                        self.getImageOrVideoFromAlbum(sourceView: sender)
                    } else {
                        showErrorDialog(error: "Please enable photo library access for this app in the phone settings.")
                    }
                }
            } else {
                self.images!.remove(at: index)
                self.delegate?.imagesChanged(images: images!)
            }
        }
    }
    
    private func getImageOrVideoFromAlbum( sourceView: UIView) {
        self.imagePicker.present(from: sourceView)
    }
    
    private func showMantis(image: UIImage) {
        var config = Mantis.Config()
        config.cropToolbarConfig.toolbarButtonOptions = [.clockwiseRotate, .reset, .ratio, .alterCropper90Degree];
        
        let cropViewController = Mantis.cropViewController(image: image,
                                                           config: config)
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.delegate = self
        parentVC?.present(cropViewController, animated: true)
    }
    
    private func uploadPhoto(photo: UIImage) {
        if profileImages != nil {
            FullScreenSpinner().show()
            userManager!.uploadProfilePhoto(userID: userManager!.realUser!.identifier, photo: photo, updateProfile: false, completion: { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                if let photo = result {
                    self.profileImages!.append(photo)
                    self.delegate?.profileImagesChanged(profileImages: self.profileImages!)
                } else {
                    showErrorDialog(error: "Failed to upload photo")
                }
            })
        } else if images != nil {
            self.images!.append(photo)
            self.delegate?.imagesChanged(images: images!)
        }
    }
}

extension SetupUploadPhotosCell: ImagePickerDelegate {
    func didSelectImage(image: UIImage?) {
        guard let image = image else {
            return
        }
        
        showMantis(image: image)
    }
    
    func didSelectVideo(video: PHAsset?) {
        
    }
}

extension SetupUploadPhotosCell: CropViewControllerDelegate {
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        
    }
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
        
    }
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
        
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        print(transformation);
        parentVC?.dismiss(animated: true, completion: { [weak self] in
            self?.uploadPhoto(photo: cropped)
        })
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        parentVC?.dismiss(animated: true)
    }
}
