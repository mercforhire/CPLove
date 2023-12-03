//
//  CupidProfilePhotosCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-01.
//

import UIKit
import ImageViewer
import Kingfisher

class CupidProfilePhotosCell: UITableViewCell {

    var photos: [PhotoResponse] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    weak var viewController: UIViewController?
    
    private var galleryItems: [GalleryItem] {
        var galleryItems: [GalleryItem] = []
        
        for photo in photos {
            guard let url = URL(string: photo.photoUrl) else { continue }
            
            let myFetchImageBlock: FetchImageBlock = { imageCompletion in
                ImageDownloader.default.downloadImage(with: url,
                                                      options: [],
                                                      progressBlock: nil) { result in
                    switch result {
                    case .success(let result):
                        imageCompletion(result.image)
                    default:
                        imageCompletion(nil)
                    }
                }
            }
            
            let itemViewControllerBlock: ItemViewControllerBlock = { index, itemCount, fetchImageBlock, configuration, isInitialController in
                return AnimatedViewController(index: index, itemCount: self.photos.count, fetchImageBlock: myFetchImageBlock, configuration: configuration, isInitialController: isInitialController)
            }
            
            let galleryItem = GalleryItem.custom(fetchImageBlock: myFetchImageBlock, itemViewControllerBlock: itemViewControllerBlock)
            galleryItems.append(galleryItem)
        }
        
        return galleryItems
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pictureCount: UILabel!
    
    @IBOutlet weak var buttonContainer1: UIView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    var heartTapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    
    @IBOutlet weak var buttonContainer2: UIView!
    @IBOutlet weak var chatButton: UIButton!
    var chatTapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.dataSource = self
        collectionView.delegate = self
        
        heartButton.addGestureRecognizer(heartTapGesture)
        buttonContainer2.addGestureRecognizer(chatTapGesture)
        
        buttonContainer1.roundCorners(style: .completely)
        buttonContainer2.roundCorners(style: .completely)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(user: UserInfo) {
        photos = user.personalPhotos ?? []
        heartButton.tintColor = user.isLiked ?? false ? themeManager.themeData!.pink.hexColor : .white
        likesCountLabel.text = "\(user.likeAmount ?? 0)"
        refreshPictureCount()
    }

    private func showGalleryImageViewer(startIndex: Int) {
        var config = GalleryConfiguration()
        config.append(.closeButtonMode(.builtIn))
        config.append(.seeAllCloseButtonMode(.none))
        config.append(.deleteButtonMode(.none))
        let gVC = GalleryViewController(startIndex: startIndex, itemsDataSource: self, configuration: config)
        viewController?.presentImageGallery(gVC)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        refreshPictureCount()
    }
    
    func refreshPictureCount() {
        guard let centerCell = collectionView.centerMostCell, let indexPath = collectionView.indexPath(for: centerCell) else {
            pictureCount.text = "1/\(photos.count)"
            return
        }
        
        pictureCount.text = "\(indexPath.row + 1)/\(photos.count)"
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally, animated: true)
    }
}

extension CupidProfilePhotosCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePhotoCell", for: indexPath) as! SimpleImageCell
        
        let photo = photos[indexPath.row]
        cell.config(data: photo, blurred: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !photos.isEmpty {
            showGalleryImageViewer(startIndex: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
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
}

extension CupidProfilePhotosCell: GalleryItemsDataSource {
    func itemCount() -> Int {
        return galleryItems.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return galleryItems[index]
    }
}
