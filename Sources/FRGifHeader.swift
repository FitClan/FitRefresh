//
//  GifHeader.swift
//  FitRefresh
//
//  Created by Cyrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

class FRGifHeader: FRStateHeader {
    
    //MARK: 方法接口
    /** 设置刷新状态下,gif的图片 */
    @discardableResult
    open func setImages(_ images:Array<UIImage>, state:RefreshState) -> Self {
        
        return self.setImages(images, duration: TimeInterval(images.count) * 0.1, state: state)
    }
    
    /** 设置刷新状态下,gif的图片,动画每帧相隔的时间 */
    @discardableResult
    open func setImages(_ images:Array<UIImage>, duration:TimeInterval, state:RefreshState) -> Self {
        //防止空数组 []
        if images.count < 1 { return self}
        
        self.stateImages[state] = images;
        self.stateDurations[state] = duration;
        
        //根据图片设置控件的高度
        let image:UIImage = images.first!
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
    
    
    //MARK: 重写
    override open var pullingPercent:CGFloat {
        didSet{
            if  let images = self.stateImages[RefreshState.idle] {
                
                if self.state != RefreshState.idle || images.count < 1 { return }
                
                //停止动画
                self.gifView.stopAnimating()
                //设置当前需要显示的图片,根据百分比显示
                var index = Int(CGFloat(images.count) * pullingPercent)
                
                if index >= images.count { index = images.count - 1 }
                
                self.gifView.image = images[index]
            }
        }
    }
    
    override func placeSubvies() {
        super.placeSubvies()
        
        self.gifView.frame = self.bounds
        if self.stateLabel.isHidden && self.lastUpdatedTimeLabel.isHidden {
            self.gifView.contentMode = UIViewContentMode.center
        }else {
            self.gifView.contentMode = UIViewContentMode.right
            self.gifView.width = self.width * 0.5 - RefreshGifViewWidthDeviation
        }
    }
    
    override var state:RefreshState{
        didSet{
            if state == oldValue { return }
            self.switchStateDoSomething(state)
        }
    }
    
    fileprivate func switchStateDoSomething(_ state:RefreshState){
        
        if !(state == RefreshState.pulling || state == RefreshState.refreshing) { return }
        
        if let images = self.stateImages[state] {
            if images.count < 1 { return }
            
            self.gifView.stopAnimating()
            //单张图片
            if images.count == 1 {
                self.gifView.image = images.last
                //多张图片
            } else {
                self.gifView.animationImages = images
                self.gifView.animationDuration = self.stateDurations[state]!
                self.gifView.startAnimating()
            }
        }
        
    }

}
