//
//  Created by Kordian Ledzion on 17.05.2017.
//  Copyright © 2017 Droids on Roids. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    @IBOutlet private weak var takePhotoButton: TakePhotoButton!
    @IBOutlet private weak var takePhotoButtonWidth: NSLayoutConstraint!
    @IBOutlet private weak var takePhotoButtonHeight: NSLayoutConstraint!
    @IBOutlet private weak var previewView: UIView!
    
    private var session: AVCaptureSession!
    private let captureSessionQueue = DispatchQueue(label: "captureSessionQueue", attributes: [], target: nil)
    private var imageOutput: AVCaptureStillImageOutput!
    private var captureViewPreviewLayer: AVCaptureVideoPreviewLayer!
    private var isSelfieCameraEnabled = false
    private var isFlashEnabled = false
    private var previewImageView: UIImageView?
    
    private var frontCamera: AVCaptureDevice? {
        for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
            if let captureDevice = device as? AVCaptureDevice, (device as AnyObject).position == .front {
                return captureDevice
            }
        }
        return nil
    }
    
    private var backCamera: AVCaptureDevice? {
        return AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) ?? nil
    }

    
    private struct Constants {
        static let constraintsSizeDefault: CGFloat = 50.0
        static let constraintsSizeAfterAnimation: CGFloat = 65.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateBackground()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCamera()
    }
    
    func configureCamera() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        session.beginConfiguration()
        imageOutput = AVCaptureStillImageOutput()
        captureSessionQueue.async {
            let outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            self.imageOutput.outputSettings = outputSettings
            if self.session.canAddOutput(self.imageOutput) {
                self.session.addOutput(self.imageOutput)
            }
            
            self.session.commitConfiguration()
            self.setupBackCamera()
        }
    }
    
    private func setupBackCamera() {
        guard let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        let input = try? AVCaptureDeviceInput(device: isSelfieCameraEnabled ? frontCamera : backCamera)
        session.addInput(input)
        session.startRunning()
        DispatchQueue.main.async {
            self.captureViewPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            self.captureViewPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.captureViewPreviewLayer.frame = self.previewView.frame
            self.previewView.layer.addSublayer(self.captureViewPreviewLayer)
        }
    }
    
    private func animateBackground() {
        UIView.animate(withDuration: 2.0) { 
            self.view.backgroundColor = .black
        }
    }
    
    private func changeConstraintsConstantWithValue(value: CGFloat) {
        [takePhotoButtonWidth, takePhotoButtonHeight].forEach { constraint in
            constraint.constant = value
        }
    }
    
    @IBAction private func takePhotoButtonAction(sender: UIButton) {
        takePhotoButton.animateColor()
        
        changeConstraintsConstantWithValue(value: Constants.constraintsSizeAfterAnimation)
        
        UIView.animate(withDuration: 0.35, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.changeConstraintsConstantWithValue(value: Constants.constraintsSizeDefault)
            UIView.animate(withDuration: 0.35, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
        capturePhoto()
    }
    
    private func capturePhoto() {
        guard let videoConnection = imageOutput.connection(withMediaType: AVMediaTypeVideo) else { return }
        videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
        imageOutput.captureStillImageAsynchronously(from: videoConnection) { (dataBuffer, error) in
            
            guard let buffer = dataBuffer, let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer) else { return }
            let provider = CGDataProvider(data: imageData as CFData)
            let cgImage = CGImage(jpegDataProviderSource: provider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
            let image = UIImage(cgImage: cgImage!, scale: 1.0, orientation:  self.isSelfieCameraEnabled ? UIImageOrientation.leftMirrored : UIImageOrientation.right)
            self.showPreviewWith(image: image)
        }
    }
    
    private func showPreviewWith(image: UIImage) {
        guard let previewViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "preview") as? PreviewViewController else { return }
        
        previewViewController.modalTransitionStyle = .crossDissolve
        previewViewController.image = image
        
        present(previewViewController, animated: true, completion: nil)
    }
    
    func hidePreviewPhoto() {
        previewImageView?.removeFromSuperview()
    }
    
    
    @IBAction func flashButtonAction(_ sender: UIButton) {
        guard let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        isFlashEnabled = !isFlashEnabled
        sender.setImage(UIImage(named: isFlashEnabled ? "flashOnIcon" : "flashOffIcon"), for: UIControlState.normal)
        try? backCamera.lockForConfiguration()
        backCamera.flashMode = isFlashEnabled ? AVCaptureFlashMode.on : AVCaptureFlashMode.off
        backCamera.unlockForConfiguration()
    }
    
    @IBAction func changeCameraAction(_ sender: UIButton) {
        guard let currentCameraInput = session.inputs.first as? AVCaptureInput else { return }
        isSelfieCameraEnabled = !isSelfieCameraEnabled
        session.beginConfiguration()
        session.removeInput(currentCameraInput)
        session.sessionPreset = AVCaptureSessionPresetPhoto
        self.configureCamera()
    }
}
