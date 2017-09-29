//
//  AutoFooter.swift
//  FitRefresh
//
//  Created by Cyrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

public class FRAutoFooter: FRFooter {
    // MARK: - public
    /** 是否自动刷新(默认为YES) */
    public var automaticallyRefresh: Bool = true
    
    /** 当底部控件出现多少时就自动刷新(默认为1.0，也就是底部控件完全出现时，才会自动刷新) */
    //    @available(*, deprecated=1.0, message="Use -automaticallyChangeAlpha instead.")
    var appearencePercentTriggerAutoRefresh: CGFloat = 1.0 {
        willSet {
            self.triggerAutomaticallyRefreshPercent = newValue
        }
    }
    
    /** 当底部控件出现多少时就自动刷新(默认为1.0，也就是底部控件完全出现时，才会自动刷新) */
    public var triggerAutomaticallyRefreshPercent: CGFloat = 1.0
    
    
    // MARK: 重写
    // 初始化
    override public func willMove(toSuperview newSuperview: UIView?) {
        
        super.willMove(toSuperview: newSuperview)
        
        if let _ = newSuperview {
            if self.isHidden == false {
                self.scrollView.insertBottom += self.height
            }
            // 设置位置
            self.y = self.scrollView.contentH
            
        } else { // 被移除了两种结果，一种是手动移除，一种是父控件消除
            // TODO:防止 是 空的
            if let realScrollView = self.scrollView {
                if self.isHidden == false {
                    realScrollView.insertBottom -= self.height
                }
            }
        }
    }
    
    // MARK: 实现父类的接口
    override func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change)
        
        // 设置位置
        self.y = self.scrollView.contentH
    }
    
    override func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        
        if self.state != RefreshState.idle || !self.automaticallyRefresh || self.y == 0 { return }
        
        if self.scrollView.insertTop + self.scrollView.contentH > self.scrollView.height {
            // 内容超过一个屏幕
            // TODO: 计算公式，判断是不是在拖在到了底部
            if self.scrollView.offSetY >= self.scrollView.contentH - self.scrollView.height + self.scrollView.insertBottom + self.height * self.triggerAutomaticallyRefreshPercent - self.height {
                
                self.beginRefreshing()
                
            }
        }
    }
    
    override func scrollViewPanStateDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewPanStateDidChange(change)
        
        
        if self.state != RefreshState.idle { return }
        
        // 2.1.1 抬起
        if self.scrollView.panGestureRecognizer.state == UIGestureRecognizerState.ended {
            
            // 2.2.1.1 不够一个屏幕的滚动 top + content.height 就是内容显示的高度
            if self.scrollView.insertTop +
                self.scrollView.contentH <= self.scrollView.height {
                // 向上拖拽
                if self.scrollView.offSetY >= -self.scrollView.insertTop {
                    beginRefreshing()
                }
                // 2.1.1.2 超出一个屏幕 也就是scrollView的
            } else {
                // 拖拽到了底部
                if self.scrollView.offSetY >= self.scrollView.contentH + self.scrollView.insertBottom - self.scrollView.height {
                    beginRefreshing()
                }
                
            }
        }
    }
    
    override var state: RefreshState {
        didSet {
            if state == oldValue { return }
            if state == RefreshState.refreshing {
                FRDelay(0.5, task: {
                    self.executeRefreshingCallback()
                })
            }
        }
    }
    
    
    override public var isHidden:Bool {
        didSet {
            // 如果之前没有隐藏的现在隐藏了，那么要设置状态和去掉底部区域
            if !oldValue && isHidden {
                self.state = RefreshState.idle
                self.scrollView.insertBottom -= self.height
                
                // 如果之前是隐藏的，现在没有隐藏了，那么要增加底部区域
            } else if oldValue && !isHidden {
                self.scrollView.insertBottom += self.height
                
                // 设置位置
                self.y = self.scrollView.contentH
            }
        }
    }
}
