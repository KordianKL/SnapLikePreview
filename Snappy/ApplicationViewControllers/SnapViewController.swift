//
//  Created by Kordian Ledzion on 17.05.2017.
//  Copyright © 2017 Droids on Roids. All rights reserved.
//

import UIKit
import Alamofire

class SnapViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    private let snap: Snap
    private var timer: Timer?
    
    init(snap: Snap){
        self.snap = snap
        super.init(nibName: "SnapViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("XD")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        imageView.addGestureRecognizer(tapGesture)
        downloadImage()
    }
    
    func tapAction(){
        timer?.invalidate()
        timer = nil
        
        removeImage()
    }
    
    func timerAction(){
        removeImage()
    }
    
    private func removeImage(){
        let endpoint = Endpoint.removePhoto(filename: snap.fileName, toUserId: nil)
        
        API.request(endpoint) { [weak self] success, response in
            print("remove success: \(success)")
            if success {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func downloadImage() {
        guard let url = URL(string: snap.url) else { return }
        let request = URLRequest(url: url)
        Alamofire.request(request).responseData { [weak self] response in
            guard let data = response.data, let weakSelf = self else { return }
            
            weakSelf.timer = Timer.scheduledTimer(timeInterval: 5.0, target: weakSelf, selector: #selector(weakSelf.timerAction), userInfo: nil, repeats: false)
            weakSelf.imageView.image = UIImage(data: data, scale: 1.0)
        }
    }
}
