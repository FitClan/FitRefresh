//
//  FRBackStateFooter.swift
//  FitRefresh
//
//  Created by cyrill on 2018/2/1.
//  Copyright © 2018年 Cyrill. All rights reserved.
//

import UIKit

class FRBackStateFooter: FRBackFooter {

    // MARK: - public
    
    /// 文字距离菊花，箭头的距离
    public var labelLeftInset: CGFloat = 20
    
    /// 显示刷新状态的label
    lazy var stateLabel: UILabel = {
        [unowned self] in
        let label = UILabel.FRLabel()
        self.addSubview(label)
        return label
        }()
    
    /// 设置状态的显示文字
    public func setTitle(_ title: String?, state:RefreshState) {
        if let text = title {
            self.stateTitles[self.state] = text
            self.stateLabel.text = self.stateTitles[self.state]
        }
    }
    
    /// 获取state状态下的title
    public func title(forState state: RefreshState) -> String? {
        return self.stateTitles[self.state]
    }
    
    // MARK: - private
    /// 每个状态对应的文字 
    fileprivate var stateTitles: Dictionary<RefreshState, String> = [
        RefreshState.idle : RefreshBackFooterIdleText,
        RefreshState.pulling : RefreshBackFooterPullingText,
        RefreshState.refreshing : RefreshBackFooterRefreshingText,
        RefreshState.noMoreData : RefreshBackFooterNoMoreDataText
    ]
    
    override func prepare() {
        super.prepare()
        self.stateLabel.text = self.stateTitles[state]
    }
    
    override func placeSubvies() {
        super.placeSubvies()
        if self.stateLabel.constraints.count > 0 { return }
        self.stateLabel.frame = self.bounds
    }
    
    /// 状态
    override var state: RefreshState {
        didSet {
            if oldValue == state { return }
            
            // 设置状态文字
            self.stateLabel.text = self.stateTitles[state]
        }
    }

}
