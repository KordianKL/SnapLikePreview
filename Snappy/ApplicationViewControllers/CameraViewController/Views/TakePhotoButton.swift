//
//  Created by Kordian Ledzion on 17.05.2017.
//  Copyright © 2017 Droids on Roids. All rights reserved.
//

import UIKit

class TakePhotoButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        setTitle("", for: .normal)
        backgroundColor = .clear
        layer.borderWidth = 3.0
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = frame.width / 2.0
        layer.masksToBounds = true
    }
    
    func animateColor() {
        UIView.animate(withDuration: 0.35, animations: {
           self.backgroundColor = .red
        }) { _ in
            UIView.animate(withDuration: 0.35, animations: {
                self.backgroundColor = .clear
            })
        }
    }
}
