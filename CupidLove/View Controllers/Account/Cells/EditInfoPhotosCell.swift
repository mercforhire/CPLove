//
//  EditInfoPhotosCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit
import PhotosUI
import Mantis

class EditInfoPhotosCell: UITableViewCell {
    static let MaxPhotosCount = 9
    
    weak var parentVC: UIViewController? {
        didSet {
            guard let parentVC = parentVC, imagePicker == nil else { return }
            
            imagePicker = ImagePicker(presentationController: parentVC,
                                      delegate: self)
        }
    }
    weak var userManager: UserManager?
    private var user: MyUserInfo {
        return userManager!.realUser!
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private var imagePicker: ImagePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.dragInteractionEnabled = true
        collectionView.dropDelegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(userManager: UserManager) {
        self.userManager = userManager
        collectionView.reloadData()
    }

    private func swapPhotoPositions(source: Int, destination: Int) {
        var params = UpdateUserParams()
        params.personalPhotos = user.personalPhotos
        params.personalPhotos?.swapAt(source, destination)
        
        FullScreenSpinner().show()
        userManager?.updateProfile(params: params, completion: { [weak self] success in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            if success {
                self.refreshUser()
            }
        })
    }
    
    @objc func bottomRightButtonPressed(_ sender: UITapGestureRecognizer) {
        guard let sourceView = sender.view else { return }
        
        let index = sourceView.tag
        let currentPhotosCount: Int = userManager?.realUser?.personalPhotos?.count ?? 0

        if index >= currentPhotosCount {
            requestPhotoPermission { [weak self] hasPermission in
                guard let self = self else { return }

                if hasPermission {
                    self.getImageOrVideoFromAlbum(sourceView: sourceView)
                } else {
                    showErrorDialog(error: "Please enable photo library access for this app in the phone settings.")
                }
            }
        } else if currentPhotosCount == 1 {
            showErrorDialog(error: "Can not delete last photo")
        } else {
            FullScreenSpinner().show()
            userManager?.deleteProfilePhoto(index: index, updateProfile: true, completion: { [weak self] success in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                if success {
                    self.collectionView.reloadData()
                } else {
                    showErrorDialog(error: "Failed to delete photo")
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    private func getImageOrVideoFromAlbum(sourceView: UIView) {
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
        FullScreenSpinner().show()
        userManager?.uploadProfilePhoto(userID: user.identifier,
                                        photo: photo,
                                        updateProfile: true,
                                        completion: { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            if result != nil {
                self.refreshUser()
            } else {
                showErrorDialog(error: "Failed to upload photo")
            }
        })
    }
    
    private func refreshUser() {
        userManager?.fetchUser(initialize: false, completion: { [weak self] success in
            self?.collectionView.reloadData()
        })
    }
}

extension EditInfoPhotosCell: ImagePickerDelegate {
    func didSelectImage(image: UIImage?) {
        guard let image = image else {
            return
        }
        
        showMantis(image: image)
    }
    
    func didSelectVideo(video: PHAsset?) {
        
    }
}

extension EditInfoPhotosCell: CropViewControllerDelegate {
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

extension EditInfoPhotosCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width / 3.0
        let yourHeight = collectionView.bounds.width / 3.0

        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EditInfoPhotosCell.MaxPhotosCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditPhotoCell", for: indexPath) as! EditPhotoCell
        if indexPath.row < (userManager?.realUser?.personalPhotos?.count ?? 0), let photo = userManager?.realUser?.personalPhotos?[indexPath.row] {
            cell.config(data: photo)
        } else {
            cell.resetCell()
        }
        cell.buttonTap.view?.tag = indexPath.row
        cell.buttonTap.addTarget(self, action: #selector(bottomRightButtonPressed(_:)))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension EditInfoPhotosCell: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.row < (userManager?.realUser?.personalPhotos?.count ?? 0),
           let photoId = userManager?.realUser?.personalPhotos?[indexPath.row].thumbnailUrl {
            let item = NSItemProvider(object: photoId as NSItemProviderWriting)
            let dragItem = UIDragItem(itemProvider: item)
            return [dragItem]
        }
        
        return []
    }
}

extension EditInfoPhotosCell: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
                destinationIndexPath.row < (userManager?.realUser?.personalPhotos?.count ?? 0) else {
            return
        }
        
        coordinator.items.forEach { dropItem in
            guard let sourceIndexPath = dropItem.sourceIndexPath else {
                return
            }
            
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: { [weak self] _ in
                coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
                self?.swapPhotoPositions(source: sourceIndexPath.row, destination: destinationIndexPath.row)
            })
        }
    }
}
