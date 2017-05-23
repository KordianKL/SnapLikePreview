//
//  Created by Kordian Ledzion on 17.05.2017.
//  Copyright © 2017 Droids on Roids. All rights reserved.
//

import UIKit
import Photos

class PreviewViewController: UIViewController {

    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    private var filteredImage: UIImage?
    private var imageSaved = false
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        previewImageView.image = image
    }
    
    private func setFilteredImage() {
        if let filteredImage = filteredImage {
            previewImageView.image = filteredImage
        
            return
        }
        
        guard let image = image else { return }
        
        let filter = CIFilter(name: "CISepiaTone")
        filter?.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: kCIInputIntensityKey)
        
        guard let outputImage = filter?.outputImage?.applyingFilter("CIColorControls", withInputParameters: [kCIInputBrightnessKey: 0.2, kCIInputSaturationKey: 0.5, kCIInputContrastKey: 0.5]),
            let eaglContext = EAGLContext(api: .openGLES3) else { return }
        
        let context = CIContext(eaglContext: eaglContext)
        
        if let imageFromContext = context.createCGImage(outputImage, from: outputImage.extent) {
            filteredImage = UIImage(cgImage: imageFromContext, scale: image.scale, orientation: image.imageOrientation)
            previewImageView.image = filteredImage
        }
    }
    
    private func crop(image: UIImage) -> UIImage {
        let screenRatio = UIScreen.main.bounds.width / UIScreen.main.bounds.height
        let imageWidth = image.size.height * screenRatio
        let imageOriginX = (image.size.width - imageWidth) / 2.0
        let imageRect = CGRect(x: imageOriginX, y: 0.0, width: imageWidth, height: image.size.height)
        
        if let croppedImage = image.cgImage?.cropping(to: imageRect) {
            return UIImage(cgImage: croppedImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return UIImage()
    }
    
    @IBAction private func segmentedControlAction(_ sender: Any) {
        imageSaved = false
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            previewImageView.image = image
        default:
            setFilteredImage()
        }
    }
    
    @IBAction private func saveButtonAction(_ sender: Any) {
        guard let image = previewImageView.image, !imageSaved else { return }
        
        let croppedImage = crop(image: image.fixImageOrientation())
        
        PHPhotoLibrary.shared().performChanges({ 
            PHAssetChangeRequest.creationRequestForAsset(from: croppedImage)
        }, completionHandler: { [weak self] completion, _ in
            if completion {
                self?.imageSaved = true
            }
        })
    }
    
    @IBAction private func closeButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        guard let image = previewImageView.image?.fixImageOrientation() else { return }
        
        let croppedImage = crop(image: image)
        let sizeRatio = croppedImage.size.height / croppedImage.size.width
        let maxSize: CGFloat = 1000.0
        let newSize = CGSize(width: maxSize / sizeRatio, height: maxSize)
        let scaledImage = croppedImage.resized(newSize: newSize)
        
        let endpoint = Endpoint.uploadPhoto(image: scaledImage, fromUserId: 1, toUserId: nil)
        
        sender.isEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        API.request(endpoint) { success in
            sender.isEnabled = true
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("Upload success: \(success)")
        }
    }
}
