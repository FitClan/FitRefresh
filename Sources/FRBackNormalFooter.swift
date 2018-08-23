//
//  FRBackNormalFooter.swift
//  FitRefresh
//
//  Created by cyrill on 2018/2/1.
//  Copyright © 2018年 Cyrill. All rights reserved.
//

import UIKit

class FRBackNormalFooter: FRBackStateFooter {

    // MARK: - public
    /// 箭头view
    lazy var arrowView: UIImageView = {
        [unowned self] in
        
        var image = UIImage(named: FRIconSrcPath)
        if image == nil {
            image = UIImage(named: FRIconLocalPath)
        }
        let imageView = UIImageView(image: image)
        self.addSubview(imageView)
        
        return imageView
    }()
    
    // MARK: - public
    /// loading样式 
    public var activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray {
        didSet {
            self.activityView.activityIndicatorViewStyle = activityIndicatorViewStyle
            self.setNeedsLayout()
        }
    }
    
    // MARK: - private
    // loading
    lazy var activityView: UIActivityIndicatorView = {
        [unowned self] in
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: self.activityIndicatorViewStyle)
        activityView.hidesWhenStopped = true
        self.addSubview(activityView)
        return activityView
        }()
    
    
    // MARK: 重写 rewrite
    override func placeSubvies() {
        super.placeSubvies()
        
        // loading
        var activityViewCenterX = self.width * 0.5
        if !self.stateLabel.isHidden {
            activityViewCenterX -= self.stateLabel.fr_textWidth * 0.5 + self.labelLeftInset
            
        }
        let activityViewCenterY = self.height * 0.5
        let activityCenter = CGPoint(x: activityViewCenterX, y: activityViewCenterY)
        
        // 箭头
        if self.arrowView.constraints.count == 0 {
            self.arrowView.size = self.arrowView.image!.size
            self.arrowView.center = activityCenter
        }
        
        // 菊花
        if self.activityView.constraints.count == 0 {
            self.activityView.center = activityCenter
        }
        
        self.arrowView.tintColor = self.stateLabel.textColor
    }
    
    override var state: RefreshState {
        didSet {
            if oldValue == state { return }
            if state == RefreshState.idle {
                if oldValue == .refreshing {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: CGFloat(0.000001 - .pi))
                    UIView.animate(withDuration: RefreshSlowAnimationDuration, animations: {
                        [unowned self] () -> Void in
                        self.activityView.alpha = 0.0
                    }, completion: { (_) in
                        self.activityView.alpha = 1.0
                        self.activityView.stopAnimating()
                        
                        self.arrowView.isHidden = false
                    })
                } else {
                    self.arrowView.isHidden = false
                    self.activityView.stopAnimating()
                    UIView.animate(withDuration: RefreshFastAnimationDuration, animations: {
                        [unowned self] () -> Void in
                        self.arrowView.transform = CGAffineTransform(rotationAngle: CGFloat(0.000001 - .pi))
                    })
                }
            } else if state == RefreshState.pulling  {
                self.arrowView.isHidden = false
                self.activityView.stopAnimating()
                UIView.animate(withDuration: RefreshFastAnimationDuration, animations: {
                    [unowned self] () -> Void in
                    self.arrowView.transform = CGAffineTransform.identity
                })
            } else if state == RefreshState.refreshing {
                self.arrowView.isHidden = true
                self.activityView.startAnimating()
            } else if state == RefreshState.noMoreData {
                self.arrowView.isHidden = true
                self.activityView.stopAnimating()
            }
        }
    }
}
