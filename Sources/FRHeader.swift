//
//  Header.swift
//  FitRefresh
//
//  Created by CYrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

public class FRHeader: FRComponent {

    // MARK: - public
    
    /** 利用这个key来保存上次的刷新时间（不同界面的刷新控件应该用不同的dateKey，以区分不同界面的刷新时间） */
    var lastUpdatedateKey = ""
    
    /** 忽略多少scrollView的contentInset的top */
    public var ignoredScrollViewContentInsetTop: CGFloat = 0.0
    
    /** 上一次下拉刷新成功的时间 */
    public var lastUpdatedTime: Date {
        get {
            if let realTmp =  UserDefaults.standard.object(forKey: self.lastUpdatedateKey){
                
                return realTmp as! Date
            } else {
                return Date()
            }
        }
    }
    
    // MARK: 覆盖父类方法
    override func prepare() {
        super.prepare()
        
        // 设置key
        self.lastUpdatedateKey = RefreshHeaderLastUpdatedTimeKey
        
        // 设置高度
        self.height = RefreshHeaderHeight
        
    }
    
    override func placeSubvies() {
        super.placeSubvies()
        
        // 设置y值(当自己的高度发生改变了，肯定要重新调整Y值，所以放到placeSubviews方法中设置y值)
        self.y = -self.height - self.ignoredScrollViewContentInsetTop
    }
    
    override func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        
        // 在刷新的refreshing状态
        if self.state == RefreshState.refreshing { return }
        
        // 跳转到下一个控制器时，contentInset可能会变
        self.scrollViewOriginalInset = self.scrollView.inset
        
        let offsetY = self.scrollView.offSetY
        
        // 头部控件刚好出现的offsetY
        let happenOffsetY = -self.scrollViewOriginalInset.top
        
        // 如果是向上滚动到看不见头部控件，直接返回
        if offsetY > happenOffsetY { return }
        
        // 普通 和 即将刷新 的临界点
        let normal2pullingOffsetY = happenOffsetY - self.height
        let pullingPercent = (happenOffsetY - offsetY) / self.height
        
        // 如果正在 拖拽
        if self.scrollView.isDragging {
            self.pullingPercent = pullingPercent
            
            
            if self.state == RefreshState.idle && offsetY < normal2pullingOffsetY {
                // 转为即将刷新状态
                self.state = RefreshState.pulling
                
            } else if self.state == RefreshState.pulling && offsetY >= normal2pullingOffsetY {
                
                // 转为普通状态
                self.state = RefreshState.idle
            }
            
        } else if self.state == RefreshState.pulling {
            // 开始刷新
            self.beginRefreshing()
            
        } else if self.pullingPercent < 1 {
            self.pullingPercent = pullingPercent
        }
    }
    
    
    // MARK: 改变状态后
    /** 刷新控件的状态 */
    override var state: RefreshState {
        
        didSet {
            
            // 状态和以前的一样就不用改变
            if oldValue == state {
                return
            }
            
            // 根据状态来做一些事情
            if state == RefreshState.idle {
                if oldValue != RefreshState.refreshing { return }
                
                // 保存刷新的时间
                UserDefaults.standard.set(Date(), forKey: self.lastUpdatedateKey as String)
                
                UserDefaults.standard.synchronize()
                
                // 恢复inset和offset
                UIView.animate(withDuration: RefreshSlowAnimationDuration, animations: { [unowned self] () -> Void in
                    self.scrollView.insertTop -= self.height
                    
                    // 自动调整透明度
                    if self.automaticallyChangeAlpha {self.alpha = 0.0}
                    
                    }, completion: { [unowned self] (flag) -> Void in
                        
                        self.pullingPercent = 0.0
                })
                
            } else if state == RefreshState.refreshing {
                UIView.animate(withDuration: RefreshSlowAnimationDuration, animations: {[unowned self] () -> Void in
                    
                    let top = self.scrollViewOriginalInset.top + self.height
                    
                    // 增加滚动区域
                    self.scrollView.insertTop = top
                    
                    // 设置滚动位置
                    self.scrollView.offSetY = -top

                    }, completion: { (flag) -> Void in
                        self.executeRefreshingCallback()
                })
            }
        }
    }
    
    /** 结束刷新 */
    override public func endRefreshing() {
        
        if self.scrollView.isKind(of: UICollectionView.self){
            FRDelay(0.1, task: { 
                super.endRefreshing()
            })
        } else {
            super.endRefreshing()
        }
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
