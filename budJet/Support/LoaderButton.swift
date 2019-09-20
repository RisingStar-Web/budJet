//
//  LoaderButton.swift
//  bdpappswift
//
//  Created by neko on 31.03.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import SnapKit

class LoaderButton: UIButton {
    
    var isLoading: Bool = false;
    var activityIndicator: UIActivityIndicatorView?
    var buttonTitleColor: UIColor?
    
    func setLoading(style: UIActivityIndicatorView.Style) {
        isLoading = true
        if self.activityIndicator == nil {
            self.activityIndicator = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 25.0, height: 25.0))
            self.activityIndicator?.style = style
            self.activityIndicator?.center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
            self.activityIndicator?.startAnimating()
            self.addSubview(self.activityIndicator!)
            
            self.activityIndicator?.snp.makeConstraints { make in
                make.width.equalTo(25.0)
                make.height.equalTo(25.0)
                make.center.equalTo(self)
            }
        }
        self.isUserInteractionEnabled = false;
        
        buttonTitleColor = self.titleLabel?.textColor
        setTitleColor(UIColor.white, for: .normal)
    }
    
    func cancelLoading() {
        if self.activityIndicator != nil {
            self.isUserInteractionEnabled = true
            if buttonTitleColor != nil {
                self.setTitleColor(buttonTitleColor, for: .normal)
                buttonTitleColor = nil
            }
            self.activityIndicator?.removeFromSuperview()
            self.activityIndicator = nil
        }
    }

}
