//
//  Footer.swift
//  FitRefresh
//
//  Created by Cyrill on 2016/12/28.
//  Copyright © 2016年 Cyrill. All rights reserved.
//

import UIKit

public class FRFooter: FRComponent {
    
    // MARK: - public
    /// 提示没有更多的数据 
    public func endRefreshingWithNoMoreData() {
        DispatchQueue.main.async {
            self.state = RefreshState.noMoreData
        }
    }
    
    @available(*, deprecated, message: "使用endRefreshingWithNoMoreData", renamed: "endRefreshingWithNoMoreData")
    public func noticeNoMoreData() { self.endRefreshingWithNoMoreData() }
    
    /// 重置没有更多的数据（消除没有更多数据的状态） 
    public func resetNoMoreData() {
        DispatchQueue.main.async {
            self.state = RefreshState.idle
        }
    }
    
    /// 忽略多少scrollView的contentInset的bottom 
    public var ignoredScrollViewContentInsetBottom: CGFloat = 0
        
    // MARK: - private
    // 重写父类方法
    override func prepare() {
        super.prepare()
        self.height = RefreshFooterHeight
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if let _ = newSuperview {
            // 监听scrollView数据的变化
            // 由于闭包是Any 所以不能采用关联对象
            let tmpClass = ReloadDataClosureInClass()
            
            self.scrollView.fr.reloadDataClosureClass = tmpClass
            
        }
    }
}
