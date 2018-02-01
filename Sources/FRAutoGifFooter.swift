//
//  FRAutoGifFooter.swift
//  FitRefresh
//
//  Created by Cyrill on 2017/12/5.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

import UIKit

class FRAutoGifFooter: FRAutoStateFooter {

    // MARK: 方法接口
    /** 设置刷新状态下,gif的图片 */
    @discardableResult
    public func setImages(_ images: Array<UIImage>, state: RefreshState) -> Self {
        return self.setImages(images, duration: TimeInterval(images.count) * 0.1, state: state)
    }
    
    /** 设置刷新状态下,gif的图片,动画每帧相隔的时间 */
    @discardableResult
    public func setImages(_ images: Array<UIImage>, duration:TimeInterval, state:RefreshState) -> Self {
        // 防止空数组 []
        if images.count < 1 { return self}
        
        self.stateImages[state] = images;
        self.stateDurations[state] = duration;
        
        // 根据图片设置控件的高度
        let image: UIImage = images.first!
        if image.size.height > self.height {
            self.height = image.size.height
        }
        
        return self
    }
    
    fileprivate lazy var gifView: UIImageView = {
        [unowned self] in
        let gifView = UIImageView()
        self.addSubview(gifView)
        return gifView
        }()
    
    fileprivate var stateImages: Dictionary<RefreshState, Array<UIImage>> = [RefreshState.idle : []]
    fileprivate var stateDurations: Dictionary<RefreshState, TimeInterval> = [RefreshState.idle : 1, RefreshState.pulling : 1, RefreshState.refreshing : 1]
    
    
    // MARK: 重写
    override public func prepare() {
        super.prepare()
    }
    
    override func placeSubvies() {
        super.placeSubvies()
        
        self.gifView.frame = self.bounds
        if self.isRefreshingTitleHidden {
            self.gifView.contentMode = UIViewContentMode.center
        } else {
            self.gifView.contentMode = UIViewContentMode.right
            self.gifView.width = self.width * 0.5 - 20 - self.stateLabel.fr_textWidth() * 0.5
        }
    }
    
    override var state: RefreshState {
        didSet {
            if state == oldValue { return }
            self.switchStateDoSomething(state)
        }
    }
    
    fileprivate func switchStateDoSomething(_ state: RefreshState) {
        
        if !(state == RefreshState.pulling || state == RefreshState.refreshing) { return }
        
        if state == RefreshState.refreshing {
            if let images = self.stateImages[state] {
                if images.count < 1 { return }
                
                self.gifView.stopAnimating()
                self.gifView.isHidden = false
                // 单张图片
                if images.count == 1 {
                    self.gifView.image = images.last
                    // 多张图片
                } else {
                    self.gifView.animationImages = images
                    self.gifView.animationDuration = self.stateDurations[state]!
                    self.gifView.startAnimating()
                }
            }
        } else if (state == RefreshState.pulling || state == RefreshState.idle) {
            self.gifView.stopAnimating()
            self.gifView.isHidden = true
        }
    }

}
