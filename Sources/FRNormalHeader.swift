//
//  NormalHeader.swift
//  FitRefresh
//
//  Created by Cyrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

public class FRNormalHeader: FRStateHeader {
    // MARK: - public
    
    /** loading样式 */
    public var activityIndicatorViewStyle:UIActivityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray {
        
        didSet {
            self.activityView.activityIndicatorViewStyle = activityIndicatorViewStyle
            self.setNeedsLayout()
        }
    }
    
    /** 指示器的图片[箭头] */
    public var arrowImage: UIImage? {
        didSet {
            
            self.arrowView.image = arrowImage
            self.placeSubvies()
        }
    }
    
    // MARK: lazy
    // 图片
    /** 指示图片 */
    lazy  var arrowView: UIImageView = {
        [unowned self] in
        
        var image = UIImage(named: FRIconSrcPath)
        if image == nil {
            image = UIImage(named: FRIconLocalPath)
        }
        let imageView = UIImageView(image: image)
        self.addSubview(imageView)
        
        return imageView
        }()
    
    // loading
    fileprivate lazy var activityView: UIActivityIndicatorView = {
        
        [unowned self] in
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: self.activityIndicatorViewStyle)
        activityView.bounds = self.arrowView.bounds
        
        self.addSubview(activityView)
        
        return activityView
        }()
    
    // MARK: 重写父类方法
    override func placeSubvies() {
        super.placeSubvies()
        //箭头
        self.arrowView.size = (self.arrowView.image?.size)!
        var arrowCenterX = self.width * 0.5
        if !self.stateLabel.isHidden {
            arrowCenterX -= 100
        }
        let arrowCenterY = self.height * 0.5
        self.arrowView.center = CGPoint(x: arrowCenterX, y: arrowCenterY)
        
        // loading
        self.activityView.frame = self.arrowView.frame
    }
    
    // 重写观察者属性
    /** 辅助记录 旧值 */
    fileprivate var oldState: RefreshState!
    override var state: RefreshState {
        
        didSet {
            self.oldState = oldValue
            if state == oldValue {return}
            self.switchStateDoSomething(state)
        }
    }
    
    fileprivate func switchStateDoSomething(_ state: RefreshState){
        
        func commonFun() {
            self.activityView.stopAnimating()
            self.arrowView.isHidden = false
        }
        
        // 4.判断当前的状态
        switch state {
            
        // 4.1如果是刷新状态
        case .idle :
            
            // 4.1.1 旧值等于 真正刷新的状态
            if self.oldState == RefreshState.refreshing {
                self.arrowView.transform = CGAffineTransform.identity
                
                UIView.animate(withDuration: RefreshSlowAnimationDuration, animations: { () -> Void in
                    self.activityView.alpha = 0.0
                }, completion: { (flag) -> Void in
                    
                    // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                    if self.state != RefreshState.idle { return }
                    
                    self.activityView.alpha = 1.0
                    commonFun()
                    
                })
                
                // 4.1.2 不然就反正之前的
            } else {
                commonFun()
                UIView.animate(withDuration: RefreshSlowAnimationDuration, animations: { () -> Void in
                    self.arrowView.transform = CGAffineTransform.identity
                    
                })
            }
        // 如果继续下拉
        case .pulling:
            commonFun()
            UIView.animate(withDuration: RefreshSlowAnimationDuration, animations: { () -> Void in
                let tmp:CGFloat = 0.000001 - CGFloat(Double.pi)
                self.arrowView.transform = CGAffineTransform(rotationAngle: tmp);
            })
            
        case .refreshing:
            self.arrowView.isHidden = true
            self.activityView.alpha = 1.0 // 防止refreshing -> idle的动画完毕动作没有被执行
            self.activityView.startAnimating()
        default: break
            
        }
    }
}
