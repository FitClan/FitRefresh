//
//  FRBackFooter.swift
//  FitRefresh
//
//  Created by cyrill on 2017/12/12.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

import UIKit

class FRBackFooter: FRFooter {

    // MARK: - public
    fileprivate var lastRefreshCount: Int = 0
    fileprivate var lastBottomDelta: CGFloat = 0.0
  
    // MARK: 重写
    // 初始化
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.scrollViewContentSizeDidChange(nil)
    }
    
    // MARK: 实现父类的接口
    override func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change)
        
        // 如果正在刷新,直接返回
        if self.state == RefreshState.refreshing { return }
        
        scrollViewOriginalInset = self.scrollView.inset
        
        // 当前的contentOffset
        let currentOffsetY = self.scrollView.offSetY
        let happenOffsetY = self.happenOffsetY()
        
        // 如果是向下滚动到看不见尾部控件，直接返回
        if currentOffsetY <= happenOffsetY { return }
        
        let pullingPercent = (currentOffsetY - happenOffsetY) / self.height
        
        // 如果已经全部加载，仅设置pullingPercent，然后返回
        if self.state == RefreshState.noMoreData {
            self.pullingPercent = pullingPercent
            return
        }
        
        if self.scrollView.isDragging {
            self.pullingPercent = pullingPercent
            // 普通和即将刷新的临界点
            let normal2pullingOffsetY = happenOffsetY + self.height
            if self.state == RefreshState.idle && currentOffsetY > normal2pullingOffsetY {
                // 转为即将刷新状态
                self.state = .pulling
            } else if self.state == RefreshState.pulling && currentOffsetY <= normal2pullingOffsetY {
                // 转为普通状态
                self.state = .idle
            }
        } else if (self.state == RefreshState.pulling) {
            // 即将刷新 && 手松开
            // 开始刷新
            self.beginRefreshing()
        } else if (pullingPercent < 1) {
            self.pullingPercent = pullingPercent
        }
    }
    
    override func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        
        // 内容的高度
        let contentHeight = self.scrollView.contentH + self.ignoredScrollViewContentInsetBottom
        // 表格的高度
        let scrollHeight = self.scrollView.height - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom + self.ignoredScrollViewContentInsetBottom
        // 设置位置和尺寸
        self.y = max(contentHeight, scrollHeight)
    }
    
    override var state: RefreshState {
        didSet {
            if state == oldValue { return }
            if state == .noMoreData || state == .idle {
                if RefreshState.refreshing == oldValue {
                    UIView.animate(withDuration: RefreshSlowAnimationDuration, animations: {
                        [unowned self] () -> Void in
                        self.scrollView.insetBottom -= self.lastBottomDelta
                    }, completion: { (finished) in
                        self.pullingPercent = 0.0
                        self.endRefreshingCompletionBlock()
                    })
                }
                
            } else if state == RefreshState.refreshing {
                UIView.animate(withDuration: RefreshFastAnimationDuration, animations: {
                    [unowned self] () -> Void in
                    var bottom = self.height + self.scrollViewOriginalInset.bottom
                    let deltaH = self.heightForContentBreakView()
                    if deltaH < 0 {
                        bottom -= deltaH
                    }
                    self.lastBottomDelta = bottom - self.scrollView.insetBottom
                    self.scrollView.insetBottom = bottom
                    self.scrollView.offSetY = self.happenOffsetY() + self.height
                }, completion: { (_) in
                    self.executeRefreshingCallback()
                })
            }
        }
    }
    
    private func heightForContentBreakView() -> CGFloat {
        let h = self.scrollView.frame.size.height - self.scrollViewOriginalInset.bottom - self.scrollViewOriginalInset.top
        return self.scrollView.contentSize.height - h
    }
    
    private func happenOffsetY() -> CGFloat {
        let deltaH = self.heightForContentBreakView()
        if deltaH > 0 {
            return deltaH - self.scrollViewOriginalInset.top
        } else {
            return -self.scrollViewOriginalInset.top
        }
    }

}
